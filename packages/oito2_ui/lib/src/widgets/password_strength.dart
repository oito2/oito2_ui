// Copyright (C) 2026  OITO2
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../l10n/oito2_localizations.dart';

/// A suggestion that makes a password stronger, given by
/// [Oito2PasswordStrength.hints].
enum Oito2PasswordHint {
  /// The password is one of the most common passwords or contains one.
  avoidCommon,

  /// The password contains the user's name, email or another given input.
  avoidPersonalInfo,

  /// The password is a common English or Portuguese word or contains one.
  avoidWords,

  /// The password contains a year or a date.
  avoidDates,

  /// The password contains a run such as "abcd", "4321" or "qwerty".
  avoidSequences,

  /// The password repeats a character or a group, such as "aaaa" or
  /// "abab".
  avoidRepeats,

  /// The password is short.
  addLength,

  /// The password uses only one or two kinds of characters.
  mixCharacters;

  /// Returns the localized suggestion from [strings], such as "Add more
  /// characters".
  String labelIn(Oito2Localizations strings) => switch (this) {
    avoidCommon => strings.passwordAvoidCommon,
    avoidPersonalInfo => strings.passwordAvoidPersonalInfo,
    avoidWords => strings.passwordAvoidWords,
    avoidDates => strings.passwordAvoidDates,
    avoidSequences => strings.passwordAvoidSequences,
    avoidRepeats => strings.passwordAvoidRepeats,
    addLength => strings.passwordAddLength,
    mixCharacters => strings.passwordMixCharacters,
  };
}

/// How hard a password is to guess: a [level] from 0 (very weak) to 4
/// (strong) and the [hints] that would make it stronger, most useful
/// first.
///
/// [estimate] rates a password on the device, without sending it
/// anywhere. A field can take another estimator, such as a port of
/// zxcvbn, that returns this value.
@immutable
class Oito2PasswordStrength {
  /// Creates a strength of [level], from 0 to 4, with [hints].
  const Oito2PasswordStrength(this.level, {this.hints = const []})
    : assert(level >= 0 && level <= 4);

  /// The rating: 0 very weak, 1 weak, 2 fair, 3 good and 4 strong.
  final int level;

  /// The suggestions that would make the password stronger, most useful
  /// first; empty for a strong password.
  final List<Oito2PasswordHint> hints;

  /// Returns the localized name of [level] from [strings], such as
  /// "Weak".
  String labelIn(Oito2Localizations strings) => switch (level) {
    0 => strings.passwordVeryWeak,
    1 => strings.passwordWeak,
    2 => strings.passwordFair,
    3 => strings.passwordGood,
    _ => strings.passwordStrong,
  };

  /// Rates [password] on the device with a heuristic.
  ///
  /// The rating adds up the bits an attacker would need for each part of
  /// the password: characters drawn from the kinds the password uses
  /// (lowercase, uppercase, digits, symbols and others) cost the most,
  /// while parts an attacker tries first cost little: one of about five
  /// hundred very common passwords, one of about thirteen hundred common
  /// English and Portuguese words, a word of [userInputs] such as the
  /// user's name or the parts of an email, a year or a date, an
  /// alphabetical, numeric or keyboard run, and repeated characters or
  /// groups. Words are also found with accents removed and with
  /// look-alike digits and symbols read as letters ("0" as "o", "1" as
  /// "i" or "l", "3" as "e", "4" and "@" as "a", "5" and "$" as "s", "7"
  /// as "t", "8" as "b", "!" as "i" and "|" as "l"), whatever their case.
  ///
  /// A password that is a common password with at most six digits or
  /// symbols before or after it, such as "Senha@2024", is level 0, and a
  /// common word with such affixes, such as "Montanha@77", is at most
  /// level 1. Below 8 characters the level is at most 1.
  ///
  /// This is a quick estimate, not a guarantee: a field can take a
  /// stronger estimator, such as a port of zxcvbn, that returns this
  /// value.
  ///
  /// Returns level 0 without hints for an empty password.
  static Oito2PasswordStrength estimate(
    String password, {
    Iterable<String> userInputs = const [],
  }) {
    if (password.isEmpty) return const Oito2PasswordStrength(0);
    final chars = password.runes.map(String.fromCharCode).toList();
    final lower = chars.map((c) => c.toLowerCase()).toList();
    final readings = _readings(lower);
    final hints = <Oito2PasswordHint>{};

    final core = _coreKind(readings);
    if (core == Oito2PasswordHint.avoidCommon) {
      return Oito2PasswordStrength(
        0,
        hints: [
          Oito2PasswordHint.avoidCommon,
          if (chars.length < 12) Oito2PasswordHint.addLength,
        ],
      );
    }

    final plain = lower.join();
    final alphabet = _alphabetSize(chars);
    final perChar = math.log(alphabet) / math.ln2;
    final matches = <_Match>[
      ..._words(chars, readings, userInputs),
      ..._dates(plain),
      ..._runs(lower),
      ..._keyboardRuns(plain),
      ..._repeats(lower, perChar),
    ];

    // Takes the longest matches first, without overlaps.
    matches.sort((a, b) => (b.end - b.start).compareTo(a.end - a.start));
    final covered = List<bool>.filled(chars.length, false);
    var bits = 0.0;
    for (final match in matches) {
      if (Iterable<int>.generate(
        match.end - match.start,
        (i) => match.start + i,
      ).any((i) => covered[i])) {
        continue;
      }
      for (var i = match.start; i < match.end; i++) {
        covered[i] = true;
      }
      bits += match.bits;
      hints.add(match.hint);
    }
    bits += covered.where((c) => !c).length * perChar;

    var level = switch (bits) {
      < 28 => 0,
      < 36 => 1,
      < 50 => 2,
      < 64 => 3,
      _ => 4,
    };
    if (chars.length < 8) level = math.min(level, 1);
    if (core == Oito2PasswordHint.avoidWords) {
      level = math.min(level, 1);
      hints.add(Oito2PasswordHint.avoidWords);
    }
    if (level == 4) return const Oito2PasswordStrength(4);
    if (chars.length < 12) hints.add(Oito2PasswordHint.addLength);
    if (_kinds(chars) < 3) hints.add(Oito2PasswordHint.mixCharacters);
    final ordered = Oito2PasswordHint.values.where(hints.contains).toList();
    return Oito2PasswordStrength(level, hints: List.unmodifiable(ordered));
  }

  @override
  bool operator ==(Object other) =>
      other is Oito2PasswordStrength &&
      other.level == level &&
      listEquals(other.hints, hints);

  @override
  int get hashCode => Object.hash(level, Object.hashAll(hints));

  @override
  String toString() => 'Oito2PasswordStrength($level, $hints)';
}

/// A part of a password that an attacker tries early, from [start] to
/// [end] in characters, worth [bits] and reported with [hint].
typedef _Match = ({int start, int end, double bits, Oito2PasswordHint hint});

/// Look-alike digits and symbols and the letters they stand for; "1"
/// reads as "i" here and as "l" in a second reading.
const _leet = {
  '0': 'o',
  '1': 'i',
  '3': 'e',
  '4': 'a',
  '5': 's',
  '7': 't',
  '8': 'b',
  '@': 'a',
  r'$': 's',
  '!': 'i',
  '|': 'l',
};

/// Accented lowercase letters and the plain letters they fold to.
const _accents = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
  'ñ': 'n',
};

/// The most digits and symbols a common password or word may have
/// before and after it and still count as that password or word.
const _maxAffix = 6;

/// The longest part of a password looked up in the word lists.
const _maxWordLength = 24;

/// Very common passwords and password words, lowercase and separated by
/// spaces.
const _commonText =
    '123456 123456789 12345678 12345 1234567 1234567890 1234 111111 000000 '
    '123123 654321 666666 121212 112233 159753 147258369 147258 123321 696969 '
    '555555 777777 888888 999999 11111111 00000000 987654321 9876543210 '
    '123654 1111 2222 4444 7777 0000 1212 6969 101010 131313 159357 753951 '
    '852456 147852 258456 789456 456789 123qwe qwe123 qweasd qweasdzxc '
    'zaq12wsx zaq1zaq1 1q2w3e 1q2w3e4r 1q2w3e4r5t 1qaz2wsx 1qazxsw2 qazwsx '
    'qazwsxedc qwerty qwerty1 qwerty12 qwerty123 qwertyuiop qwertz azerty '
    'asdf asdfgh asdfghjkl asdf1234 zxcvbn zxcvbnm abcd1234 1234abcd abc123 '
    'abcdef abcd abcdefg a1b2c3 a1b2c3d4 aa123456 aaaaaa q1w2e3r4 1234qwer '
    'password password1 password12 password123 passw0rd pass pass123 passwd '
    'p4ssword pa55word iloveyou iloveu iloveyou1 loveyou lovely loveme love '
    'love123 admin admin123 administrator root toor guest user test test123 '
    'testing default changeme letmein welcome welcome1 login master secret '
    'access hello hello123 trustno1 whatever freedom monkey dragon shadow '
    'sunshine princess football baseball basketball soccer hockey superman '
    'batman spiderman starwars pokemon naruto michael jennifer jordan '
    'jordan23 hunter ashley bailey buster ginger tigger summer winter spring '
    'autumn flower cookie chocolate cheese pepper computer internet samsung '
    'google apple mustang harley ferrari porsche matrix killer angel baby '
    'family friends jesus god money charlie thomas daniel andrew joshua '
    'jessica michelle nicole robert william george maggie sophie lucky '
    'diamond silver golden orange banana purple yellow blessed blessing '
    'heaven qwerty1234 fuckyou fuckyou1 asshole 123abc abc12345 zxcv1234 '
    'marina natasha andrea carlos maria jose joao pedro lucas gabriel rafael '
    'juliana fernanda amanda camila bruna patricia mariana leticia vitoria '
    'beatriz isabela larissa daniela adriana senha senha1 senha12 senha123 '
    'senha1234 senha12345 minhasenha mudar123 123mudar mudarsenha trocar123 '
    'acesso acesso123 entrar brasil brasil123 brazil flamengo corinthians '
    'palmeiras santos gremio vasco botafogo fluminense cruzeiro saopaulo '
    'internacional atletico bahia amor amorzinho teamo deus deusefiel '
    'jesuscristo familia saudade gatinha gatinho princesa futebol vida '
    'minhavida felicidade esperanca sucesso vitoria1 meuamor mae pai mamae '
    'papai querida querido bebe docinho chocolate1 morango florzinha anjo '
    'anjinho estrela lua sol cachorro gato tigre leao jacare dinheiro casa '
    'paz alegria flores coracao loucura cerveja paralelepipedo abacaxi pipoca '
    'batata macaco banana1 xuxa naruto1 dragao rosa azul verde amarelo '
    'vermelho preto branco 102030 10203040 123senha 112233445566 1020304050 '
    'a12345 a123456 abc1234 asd123 mudar senhamudar sistema usuario '
    'administrador admin1 admin2020 admin2024 suporte teste teste123 servidor '
    'empresa trabalho escola faculdade universidade junior neto filho '
    'familia1 monster superstar rockstar sexy hottie babygirl princess1 '
    'iloveme loveyou1 forever whatever1 nothing 666 qwerty12345 1qaz 2wsx '
    '3edc qwer1234 asdfasdf zxczxc qweqwe asdasd zxcasdqwe passpass '
    'mypassword mypass newpassword secret123 superman1 batman1 pokemon1 '
    'starwars1 minecraft fortnite roblox playstation xbox nintendo gaming '
    'gamer hacker matrix1 cheese1 tinkerbell liverpool chelsea arsenal '
    'manchester barcelona realmadrid juventus yankees cowboys eagles steelers '
    'lakers dallas boston london paris america canada mexico chicago texas '
    'florida california michigan peanut buttercup butterfly snoopy scooby '
    'garfield mickey minnie disney cocacola pepsi marlboro corvette camaro '
    'mercedes yamaha honda toyota nissan ford chevy jaguar falcon phoenix '
    'thunder lightning tiger lion eagle wolf bear dolphin panther cobra viper '
    'snake hammer guitar music rocknroll metallica nirvana slipknot eminem '
    'blink182 justin bieber taylor beyonce rihanna shakira madonna elvis '
    'beatles zeppelin qwaszx 1qw23e 1q2w 147369 963852 741852963 789456123 '
    '123456a 123456q 12345a 12345q 12345qwert 1234567a 123qweasd 123456789a '
    '1234554321 1234512345 12341234 12121212 11223344 13579 135790 2468 24680 '
    '01020304 0102030405 troubador troubadour';

/// Common English and Portuguese words of four or more letters, without
/// accents, lowercase and separated by spaces.
const _wordsText =
    'minha minhas meus nosso voce esse essa este esta isto aqui todos todas '
    'mine '
    'that with have this will your from they know want been good much some '
    'time very when come here just like long make many more only over such '
    'take than them well were what about after again also back because before '
    'being below between both came could down each even every find first give '
    'great hand help high home house into keep kind last left life line '
    'little look made most move must name need never next number often other '
    'part people place point right said same school seem should show side '
    'small something sound spell still study tell their there these thing '
    'think those thought three through together under until upon water where '
    'which while white without word work world would write year young above '
    'across against almost along always among another answer around away '
    'become began begin behind believe best better black blue body book bring '
    'brother build business call care carry case cause center change child '
    'children city close cold color country course cover cross dark dead deep '
    'develop different door draw dream drive during early earth easy enough '
    'evening ever example face fact father feel field fight fire fish follow '
    'food foot force form free friend front full game girl glass government '
    'green ground group grow half happen happy hard head hear heart heat '
    'heavy history hold hope horse hour human idea important interest island '
    'king land large late laugh lead learn least leave letter level light '
    'list live machine main mark matter mean measure might mile mind minute '
    'miss month moon morning mother mountain nation nature near night north '
    'notice open order paper party past pattern person picture piece plain '
    'plan plant play power present problem produce public pull question quick '
    'quiet rain reach read ready real reason record remember rest river road '
    'rock room round rule safe science season second sense serve several '
    'shape ship short simple since sing sister size sleep slow snow soft song '
    'soon south space speak special stand star start state stay step stone '
    'stop story street strong sure surface table talk teacher thank though '
    'thousand today toward town travel tree true turn understand usual voice '
    'wait walk warm watch weather week weight west wheel whole wild wind '
    'window wish woman women wonder wood yesterday able accept account action '
    'active actual address admit adult affect afraid agency agent agree ahead '
    'allow alone already although amount analysis animal annual anything '
    'appear apply approach area argue army arrive article artist assume '
    'attack attention audience author available avoid ball bank base beat '
    'beautiful beyond bill billion blood board break brown budget building '
    'camera campaign cancer candidate capital card career catch cell central '
    'century certain chair challenge chance character charge check choice '
    'choose church citizen civil claim class clear coach collection college '
    'commercial common community company compare concern condition conference '
    'congress consider consumer contain continue control cost couple court '
    'create crime cultural culture current customer data daughter deal death '
    'debate decade decide decision defense degree democrat describe design '
    'despite detail determine difference difficult dinner direction director '
    'discover discuss disease doctor drug economic economy edge education '
    'effect effort eight either election else employee energy enjoy enter '
    'entire environment especially establish event everybody everyone '
    'everything evidence exactly exist expect experience expert explain '
    'factor fail fall fast fear federal feeling fill film final finally '
    'financial fine finger finish firm five floor focus foreign forget '
    'forward four future garden general generation goal gold hair hang health '
    'hospital hotel however huge husband identify image imagine impact '
    'improve include including increase indeed indicate individual industry '
    'information inside instead institution investment involve issue item '
    'itself join kill kitchen knowledge lady language lawyer leader legal '
    'less likely limit listen local lose loss magazine maintain major '
    'majority manage management manager market marriage material maybe media '
    'medical meet meeting member memory mention message method middle '
    'military million mission model modern moment movement movie myself '
    'national natural necessary network news newspaper nice none note occur '
    'offer office officer official others outside owner page pain painting '
    'parent particular partner patient peace perform performance perhaps '
    'period personal phone physical pick player police policy political poor '
    'popular population position positive possible pressure pretty prevent '
    'price private probably process product production professional professor '
    'program project property protect prove provide purpose push quality '
    'quite race radio raise range rate rather realize really receive recent '
    'recently recognize reduce reflect region relate relationship religious '
    'remain report represent republican require research resource respond '
    'response result return reveal rich rise risk role scene score seat '
    'security seek sell send senior series serious service seven shake share '
    'shoot shoulder sign significant similar situation skill social society '
    'soldier somebody someone sometimes sort source southern speech spend '
    'sport staff stage standard statement station stock store strategy '
    'structure student stuff style subject success successful suddenly suffer '
    'suggest support system task teach team technology television tend term '
    'terms theory therefore thus tonight total tough trade traditional '
    'training treat treatment trial trip trouble truth type unit value '
    'various victim view violence visit vote wall wear weapon whether wide '
    'wife within worker worry wrong yard yourself cherry lemon grape bread '
    'butter coffee sugar cake pizza rabbit mouse spider forest ocean beach '
    'storm crystal magic queen prince knight castle devil hell liberty '
    'justice victory pirate ninja wizard rocket planet galaxy universe '
    'battery correct staple monday tuesday wednesday thursday friday saturday '
    'sunday january february march april june july august september october '
    'november december tennis piano dance smile sweet honey kitty puppy '
    'darling lover goodbye server mobile email online para como mais isso '
    'pelo pela pode ainda depois muito sobre quando entre onde sempre mesmo '
    'agora outro outra tambem porque quem tudo nada nunca hoje ontem amanha '
    'tempo mundo pais cidade estado governo pessoa pessoas homem mulher filha '
    'irmao irma amigo amiga livro noite tarde manha semana anos hora minuto '
    'parte lugar forma caso grupo problema servico projeto processo politica '
    'sociedade historia momento verdade razao coisa coisas nome numero agua '
    'terra fogo roxo laranja cinza marrom grande pequeno novo velho melhor '
    'pior primeiro segundo ultimo certo errado facil dificil feliz triste '
    'bonito bonita lindo linda forte fraco rapido lento quente frio alto '
    'baixo longo curto cedo fazer dizer saber poder querer ficar passar dever '
    'chegar deixar levar comecar conhecer achar pensar falar viver sentir '
    'olhar chamar trazer voltar ouvir abrir fechar comer beber dormir correr '
    'andar jogar ganhar perder pagar comprar vender morar estudar trabalhar '
    'amar gostar ajudar trocar sair subir descer cantar dancar sonhar esperar '
    'acreditar lembrar esquecer escrever estar praia montanha floresta arvore '
    'flor jardim campo fazenda cavalo passaro peixe urso lobo coelho galinha '
    'vaca porco borboleta abelha formiga aranha cristo igreja santo santa '
    'senhor senhora menino menina garoto garota crianca jovem velha rapaz '
    'moca namorado namorada marido esposa noivo noiva amante tristeza '
    'liberdade sorte coragem forca segredo sonho desejo paixao alma corpo '
    'cabeca olho olhos boca perna braco cabelo sangue comida bebida cafe '
    'leite queijo carne frango arroz feijao tomate cebola alho bolo doce '
    'sorvete limao manga maca melancia vinho cachaca guarana suco banco conta '
    'cartao compra venda preco valor carro moto bicicleta onibus aviao navio '
    'trem estrada avenida bairro centro predio porta janela quarto sala '
    'cozinha banheiro cama mesa cadeira sofa televisao computador telefone '
    'celular rede arquivo pasta documento papel caneta lapis caderno aula '
    'professora aluno aluna colegio curso prova nota medico medica doenca '
    'saude remedio policia ladrao guerra exercito soldado brasileiro '
    'brasileira portugal lisboa paulo janeiro minas gerais parana catarina '
    'goias pernambuco ceara amazonas recife salvador fortaleza curitiba '
    'brasilia manaus belem natal bola jogo campeao campeonato copa mundial '
    'samba carnaval festa musica cancao banda cinema filme novela ferias '
    'viagem pascoa aniversario parabens obrigado obrigada desculpa favor '
    'tchau valeu beleza massa demais nossa caramba cara mano parceiro galera '
    'turma fevereiro marco abril maio junho julho agosto setembro outubro '
    'novembro dezembro segunda terca quarta quinta sexta sabado domingo '
    'primavera verao outono inverno chuva vento neve nuvem trovao relampago '
    'tempestade gelo pedra ouro prata ferro diamante cristal tesouro castelo '
    'principe rainha guerreiro cavaleiro pirata bruxa fada magia mistico '
    'misterio sombra escuro escuridao claro brilho estrelinha fofinho fofinha '
    'bonequinha vidaloka';

/// The very common passwords of [_commonText].
final Set<String> _common = _commonText.split(' ').toSet();

/// The common words of [_wordsText].
final Set<String> _dictionary = _wordsText.split(' ').toSet();

/// Returns the ways to read the lowercase characters of [lower]: with
/// accents folded, then also with look-alike digits and symbols read as
/// letters, once with "1" as "i" and once as "l". Every reading has one
/// entry for each character of [lower].
List<List<String>> _readings(List<String> lower) {
  final folded = [for (final c in lower) _accents[c] ?? c];
  final asI = [for (final c in folded) _leet[c] ?? c];
  final asL = [for (final c in folded) c == '1' ? 'l' : _leet[c] ?? c];
  return [
    folded,
    if (!listEquals(asI, folded)) asI,
    if (!listEquals(asL, asI)) asL,
  ];
}

/// Returns whether [c] is a letter from "a" to "z".
bool _isLetter(String c) {
  final code = c.codeUnitAt(0);
  return code >= 0x61 && code <= 0x7a;
}

/// Returns [Oito2PasswordHint.avoidCommon] when one of [readings] is a
/// common password, and [Oito2PasswordHint.avoidWords] when one is a
/// common word, either alone or between at most [_maxAffix] digits and
/// symbols; otherwise returns null.
///
/// The affixes are cut where the first and last letters of each reading
/// are, so "P@ssw0rd!" and "4dmin" read as "password" and "admin".
Oito2PasswordHint? _coreKind(List<List<String>> readings) {
  final length = readings.first.length;
  final starts = <int>{0};
  final ends = <int>{length};
  for (final reading in readings) {
    final first = reading.indexWhere(_isLetter);
    if (first < 0) continue;
    starts.add(first);
    ends.add(reading.lastIndexWhere(_isLetter) + 1);
  }
  Oito2PasswordHint? kind;
  for (final start in starts) {
    for (final end in ends) {
      if (end - start < 3 || start + length - end > _maxAffix) continue;
      for (final reading in readings) {
        final core = reading.sublist(start, end).join();
        if (_common.contains(core)) return Oito2PasswordHint.avoidCommon;
        if (end - start >= 4 && _dictionary.contains(core)) {
          kind = Oito2PasswordHint.avoidWords;
        }
      }
    }
  }
  return kind;
}

/// The keyboard rows a password run may follow, in both directions.
const _keyboardRows = [
  'qwertyuiop',
  'asdfghjkl',
  'zxcvbnm',
  '1234567890',
  'qazwsxedcrfvtgbyhnujmikolp',
];

/// Returns how many kinds of characters [chars] holds: lowercase,
/// uppercase, digits, ASCII symbols and others.
int _kinds(List<String> chars) {
  final kinds = <int>{};
  for (final c in chars) {
    kinds.add(_kindOf(c));
  }
  return kinds.length;
}

/// Returns the kind of [c]: 0 lowercase, 1 uppercase, 2 digit, 3 ASCII
/// symbol or space, 4 any other character.
int _kindOf(String c) {
  final code = c.codeUnitAt(0);
  if (code >= 0x61 && code <= 0x7a) return 0;
  if (code >= 0x41 && code <= 0x5a) return 1;
  if (code >= 0x30 && code <= 0x39) return 2;
  if (code >= 0x20 && code < 0x7f) return 3;
  return 4;
}

/// Returns the number of characters an attacker would try for each
/// position of a password made of [chars].
int _alphabetSize(List<String> chars) {
  const sizes = [26, 26, 10, 33, 100];
  final kinds = {for (final c in chars) _kindOf(c)};
  return kinds.fold(0, (sum, kind) => sum + sizes[kind]);
}

/// Finds the parts of [readings] that are words an attacker tries
/// early: the words of [userInputs], split at spaces, dots, at signs and
/// other separators and three characters or longer, the common passwords
/// and the common words, both four characters or longer.
///
/// A match costs a few bits more when its [chars] use uppercase letters
/// or when it was found only with look-alike characters read as letters.
List<_Match> _words(
  List<String> chars,
  List<List<String>> readings,
  Iterable<String> userInputs,
) {
  final user = {
    for (final input in userInputs)
      for (final word in input.toLowerCase().split(
        RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      ))
        if (word.length >= 3) word,
  };
  final matches = <_Match>[];
  for (var r = 0; r < readings.length; r++) {
    final reading = readings[r];
    for (var start = 0; start < reading.length; start++) {
      final last = math.min(reading.length, start + _maxWordLength);
      for (var end = start + 3; end <= last; end++) {
        final part = reading.sublist(start, end).join();
        final (double, Oito2PasswordHint)? found = switch (part) {
          _ when user.contains(part) => (
            4,
            Oito2PasswordHint.avoidPersonalInfo,
          ),
          _ when end - start < 4 => null,
          _ when _common.contains(part) => (8, Oito2PasswordHint.avoidCommon),
          _ when _dictionary.contains(part) => (
            11,
            Oito2PasswordHint.avoidWords,
          ),
          _ => null,
        };
        if (found == null) continue;
        final span = chars.sublist(start, end);
        final upper = span.any((c) => c != c.toLowerCase()) ? 1 : 0;
        final leet = r > 0 ? 1 : 0;
        matches.add((
          start: start,
          end: end,
          bits: found.$1 + upper + leet,
          hint: found.$2,
        ));
      }
    }
  }
  return matches;
}

/// Finds dates of six or eight digits, with or without separators, and
/// years from 1900 to 2099 inside [plain].
List<_Match> _dates(String plain) => [
  for (final m in RegExp(
    r'\d{1,2}[-/.]\d{1,2}[-/.](\d{4}|\d{2})|(19|20)\d{2}[01]\d[0-3]\d|[0-3]\d[01]\d(19|20)\d{2}',
  ).allMatches(plain))
    (start: m.start, end: m.end, bits: 15, hint: Oito2PasswordHint.avoidDates),
  for (final m in RegExp(r'(19|20)\d{2}').allMatches(plain))
    (start: m.start, end: m.end, bits: 7, hint: Oito2PasswordHint.avoidDates),
];

/// Finds runs of three or more characters whose codes rise or fall by
/// one at each step, such as "abcd" or "4321".
List<_Match> _runs(List<String> lower) {
  final matches = <_Match>[];
  var start = 0;
  while (start < lower.length - 2) {
    final step = lower[start + 1].codeUnitAt(0) - lower[start].codeUnitAt(0);
    var end = start + 1;
    if (step == 1 || step == -1) {
      while (end < lower.length &&
          lower[end].codeUnitAt(0) - lower[end - 1].codeUnitAt(0) == step) {
        end++;
      }
    }
    if (end - start >= 3) {
      matches.add((
        start: start,
        end: end,
        bits: 5 + math.log(end - start) / math.ln2,
        hint: Oito2PasswordHint.avoidSequences,
      ));
      start = end;
    } else {
      start++;
    }
  }
  return matches;
}

/// Finds runs of three or more neighboring keys of a keyboard row, in
/// either direction, inside [plain].
List<_Match> _keyboardRuns(String plain) {
  final matches = <_Match>[];
  for (final row in _keyboardRows) {
    for (final line in [row, row.split('').reversed.join()]) {
      var i = 0;
      while (i < plain.length - 2) {
        var length = 0;
        final at = line.indexOf(plain[i]);
        if (at >= 0) {
          while (i + length < plain.length &&
              at + length < line.length &&
              plain[i + length] == line[at + length]) {
            length++;
          }
        }
        if (length >= 3) {
          matches.add((
            start: i,
            end: i + length,
            bits: 6 + math.log(length) / math.ln2,
            hint: Oito2PasswordHint.avoidSequences,
          ));
          i += length;
        } else {
          i++;
        }
      }
    }
  }
  return matches;
}

/// Finds a character repeated three or more times in a row, and a group
/// of characters repeated right after itself, such as "abcabc"; each
/// repetition costs little more than the first copy at [perChar] bits a
/// character.
List<_Match> _repeats(List<String> lower, double perChar) {
  final matches = <_Match>[];
  var i = 0;
  while (i < lower.length) {
    var end = i + 1;
    while (end < lower.length && lower[end] == lower[i]) {
      end++;
    }
    if (end - i >= 3) {
      matches.add((
        start: i,
        end: end,
        bits: perChar + math.log(end - i) / math.ln2,
        hint: Oito2PasswordHint.avoidRepeats,
      ));
    }
    i = end;
  }
  final text = lower.join();
  for (var size = 2; size <= lower.length ~/ 2; size++) {
    for (var start = 0; start + size * 2 <= lower.length; start++) {
      final unit = text.substring(start, start + size);
      var end = start + size;
      while (end + size <= lower.length &&
          text.substring(end, end + size) == unit) {
        end += size;
      }
      if (end - start >= size * 2) {
        matches.add((
          start: start,
          end: end,
          bits: size * perChar + math.log((end - start) ~/ size) / math.ln2,
          hint: Oito2PasswordHint.avoidRepeats,
        ));
      }
    }
  }
  return matches;
}
