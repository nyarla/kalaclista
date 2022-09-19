{ pkgs, ... }:
with pkgs;
with perlPackages;
let
  modules = rec {
    TestNumberDelta = buildPerlPackage {
      pname = "Test-Number-Delta";
      version = "1.06";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/D/DA/DAGOLDEN/Test-Number-Delta-1.06.tar.gz";
        sha256 =
          "535430919e6fdf6ce55ff76e9892afccba3b7d4160db45f3ac43b0f92ffcd049";
      };
      meta = {
        homepage = "https://github.com/dagolden/Test-Number-Delta";
        description =
          "Compare the difference between numbers against a given tolerance";
        license = lib.licenses.asl20;
      };
    };
    TimeCrontab = buildPerlModule {
      pname = "Time-Crontab";
      version = "0.04";
      src = fetchurl {
        url = "mirror://cpan/authors/id/K/KA/KAZEBURO/Time-Crontab-0.04.tar.gz";
        sha256 =
          "b5dc7bb2c30424b41144523bdc8c90b904efedb12c736624c0c749a36395ba6f";
      };
      propagatedBuildInputs = [ ListMoreUtils SetCrontab ];
      meta = {
        homepage = "https://github.com/kazeburo/Time-Crontab";
        description = "Parser for crontab date and time field";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    JSONTiny = buildPerlPackage {
      pname = "JSON-Tiny";
      version = "0.58";
      src = fetchurl {
        url = "mirror://cpan/authors/id/D/DA/DAVIDO/JSON-Tiny-0.58.tar.gz";
        sha256 =
          "ad42e9137f5148df7fdb22aa52186b306032977bcd70d49f44a288070e4f0f23";
      };
      meta = {
        description = "Minimalistic JSON. No dependencies";
        license = lib.licenses.artistic2;
      };
    };
    Proclet = buildPerlModule {
      pname = "Proclet";
      version = "0.35";
      src = fetchurl {
        url = "mirror://cpan/authors/id/K/KA/KAZEBURO/Proclet-0.35.tar.gz";
        sha256 =
          "185a3075598c1810f7fee3fcd9ce39e22d508decd7946ce2a29af786479f928f";
      };
      buildInputs = [ ListMoreUtils ParallelScoreboard TestRequires ];
      propagatedBuildInputs = [
        DataValidator
        FileWhich
        GetoptCompactWithCmd
        LogMinimal
        Mouse
        ParallelPrefork
        StringShellQuote
        TimeCrontab
        YAMLLibYAML
      ];
      meta = {
        homepage = "https://github.com/kazeburo/Proclet";
        description = "Minimalistic Supervisor";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    MooXTypesMooseLike = buildPerlPackage {
      pname = "MooX-Types-MooseLike";
      version = "0.29";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/M/MA/MATEU/MooX-Types-MooseLike-0.29.tar.gz";
        sha256 =
          "1d3780aa9bea430afbe65aa8c76e718f1045ce788aadda4116f59d3b7a7ad2b4";
      };
      buildInputs = [ Moo TestFatal ];
      propagatedBuildInputs = [ ModuleRuntime ];
      meta = {
        description = "Some Moosish types and a type builder";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    HTML5DOM = buildPerlPackage {
      pname = "HTML5-DOM";
      version = "1.25";
      src = fetchurl {
        url = "mirror://cpan/authors/id/Z/ZH/ZHUMARIN/HTML5-DOM-1.25.tar.gz";
        sha256 =
          "a815c4bd6bada87203628f8e658d78610fdf9bd6b9dacfd10c437819416cee54";
      };
      meta = {
        description =
          "Super fast html5 DOM library with css selectors (based on Modest/MyHTML)";
        license = lib.licenses.mit;
      };
    };
    FileCopyRecursiveReduced = buildPerlPackage {
      pname = "File-Copy-Recursive-Reduced";
      version = "0.006";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/J/JK/JKEENAN/File-Copy-Recursive-Reduced-0.006.tar.gz";
        sha256 =
          "e618f993a69f4355205c58fffff6982609f28b47f646ec6e244e41b5c6707e2c";
      };
      buildInputs = [ CaptureTiny PathTiny ];
      meta = {
        homepage =
          "http://thenceforward.net/perl/modules/File-Copy-Recursive-Reduced/";
        description =
          "Recursive copying of files and directories within Perl 5 toolchain";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    DataValidator = buildPerlModule {
      pname = "Data-Validator";
      version = "1.07";
      src = fetchurl {
        url = "mirror://cpan/authors/id/G/GF/GFUJI/Data-Validator-1.07.tar.gz";
        sha256 =
          "a1f96420e93c0f77c1faeb1954701580288a5bffed57a1e434e5811965500ff1";
      };
      buildInputs = [ TestRequires ];
      propagatedBuildInputs = [ Mouse ];
      meta = {
        homepage = "https://github.com/gfx/p5-Data-Validator";
        description = "Rule based validator on type constraint system";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    GetoptCompactWithCmd = buildPerlModule {
      pname = "Getopt-Compact-WithCmd";
      version = "0.22";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/X/XA/XAICRON/Getopt-Compact-WithCmd-0.22.tar.gz";
        sha256 =
          "5b66f8f55c4ed5397f9042f9137218ab4b53f99f8701cf3ab24f86810beb89b4";
      };
      buildInputs = [ TestOutput TestRequires ];
      propagatedBuildInputs = [ TextTable ];
      meta = {
        homepage = "https://github.com/xaicron/p5-Getopt-Compact-WithCmd";
        description = "Sub-command friendly, like Getopt::Compact";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ListLazy = buildPerlPackage {
      pname = "List-Lazy";
      version = "0.3.3";
      src = fetchurl {
        url = "mirror://cpan/authors/id/Y/YA/YANICK/List-Lazy-0.3.3.tar.gz";
        sha256 =
          "cb00f5c6f0329af46fde82f688775a0b6a3fe0ceecfff390b4814a11f3b2fad7";
      };
      buildInputs = [ TestWarn ];
      propagatedBuildInputs =
        [ Clone ExporterTiny ListMoreUtils Moo MooXHandlesVia ];
      meta = {
        homepage = "https://github.com/yanick/List-Lazy";
        description = "Generate lists lazily";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    Carp = buildPerlPackage {
      pname = "Carp";
      version = "1.50";
      src = fetchurl {
        url = "mirror://cpan/authors/id/X/XS/XSAWYERX/Carp-1.50.tar.gz";
        sha256 =
          "f5273b4e1a6d51b22996c48cb3a3cbc72fd456c4038f5c20b127e2d4bcbcebd9";
      };
      meta = {
        description = "Alternative warn and die for modules";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ModuleBuildTiny = buildPerlModule {
      pname = "Module-Build-Tiny";
      version = "0.039";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/L/LE/LEONT/Module-Build-Tiny-0.039.tar.gz";
        sha256 =
          "7d580ff6ace0cbe555bf36b86dc8ea232581530cbeaaea09bccb57b55797f11c";
      };
      propagatedBuildInputs =
        [ ExtUtilsConfig ExtUtilsHelpers ExtUtilsInstallPaths ];
      meta = {
        description = "A tiny replacement for Module::Build";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    indirect = buildPerlPackage {
      pname = "indirect";
      version = "0.39";
      src = fetchurl {
        url = "mirror://cpan/authors/id/V/VP/VPIT/indirect-0.39.tar.gz";
        sha256 =
          "71733c4c348e98fdd575b44a52042428c39888a18c25656efe59ef3d7d0d27e5";
      };
      meta = {
        homepage = "http://search.cpan.org/dist/indirect/";
        description =
          "Lexically warn about using the indirect method call syntax";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    FilesysNotifySimple = buildPerlPackage {
      pname = "Filesys-Notify-Simple";
      version = "0.14";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/M/MI/MIYAGAWA/Filesys-Notify-Simple-0.14.tar.gz";
        sha256 =
          "1fda712d4ba5e1868159ed35f6f8efbfae9d435d6376f5606d533bcb080555a4";
      };
      buildInputs = [ TestSharedFork ];
      meta = {
        homepage = "https://github.com/miyagawa/Filesys-Notify-Simple";
        description = "Simple and dumb file system watcher";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ParallelForkBossWorkerAsync = buildPerlPackage {
      pname = "Parallel-Fork-BossWorkerAsync";
      version = "0.09";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/J/JV/JVANNUCCI/Parallel-Fork-BossWorkerAsync-0.09.tar.gz";
        sha256 =
          "76481f21fac3663d357fa369e70cae43e47274d34cf0924d563a3c438c7989a4";
      };
      meta = {
        description =
          "Perl extension for creating asynchronous forking queue processing applications";
      };
    };
    SetCrontab = buildPerlPackage {
      pname = "Set-Crontab";
      version = "1.03";
      src = fetchurl {
        url = "mirror://cpan/authors/id/A/AM/AMS/Set-Crontab-1.03.tar.gz";
        sha256 =
          "47e294e88d2d139e2d06dfa544b91a3cc5656a3a6dd15594dc764759fbaa86da";
      };
      meta = { description = "Expand crontab(5)-style integer lists"; };
    };
    ListMoreUtilsXS = buildPerlPackage {
      pname = "List-MoreUtils-XS";
      version = "0.430";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/R/RE/REHSACK/List-MoreUtils-XS-0.430.tar.gz";
        sha256 =
          "e8ce46d57c179eecd8758293e9400ff300aaf20fefe0a9d15b9fe2302b9cb242";
      };
      meta = {
        homepage = "https://metacpan.org/release/List-MoreUtils-XS";
        description = "Provide the stuff missing in List::Util in XS";
        license = lib.licenses.asl20;
      };
    };
    multidimensional = buildPerlPackage {
      pname = "multidimensional";
      version = "0.014";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/I/IL/ILMARI/multidimensional-0.014.tar.gz";
        sha256 =
          "12eb14317447bd15ab9799677db9eda20e784d8b113e44a5f6f11f529e862c5f";
      };
      buildInputs = [ ExtUtilsDepends ];
      propagatedBuildInputs = [ BHooksOPCheck ];
      meta = {
        homepage = "https://github.com/ilmari/multidimensional";
        description = "Disables multidimensional array emulation";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    CommonMark = buildPerlPackage {
      pname = "CommonMark";
      version = "0.290000";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/N/NW/NWELLNHOF/CommonMark-0.290000.tar.gz";
        sha256 =
          "a501b4c3ef6ca89f8703f9ed0b2dc0da878281f2b1277a7ec92902e088c2eadd";
      };
      buildInputs = [ pkgs.cmark DevelChecklib ];

      PERL_MM_OPT =
        ''INC="-I${pkgs.cmark}/include" LIBS="-L${pkgs.cmark}/lib -lcmark"'';

      meta = {
        description = "Interface to the CommonMark C library";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    barewordfilehandles = buildPerlPackage {
      pname = "bareword-filehandles";
      version = "0.007";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/I/IL/ILMARI/bareword-filehandles-0.007.tar.gz";
        sha256 =
          "4134533716d87af8fff56e250c488ad06df0a7bff48e7cf7de63ff6bc8d9c17f";
      };
      buildInputs = [ ExtUtilsDepends ];
      propagatedBuildInputs = [ BHooksOPCheck ];
      meta = {
        homepage = "https://github.com/ilmari/bareword-filehandles";
        description = "Disables bareword filehandles";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ModuleBuildPluggablePPPort = buildPerlModule {
      pname = "Module-Build-Pluggable-PPPort";
      version = "0.04";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/T/TO/TOKUHIROM/Module-Build-Pluggable-PPPort-0.04.tar.gz";
        sha256 =
          "44084ba3d8815f343bd391585ac5d8339a4807ce5c0dd84c98db8f310b64c0ea";
      };
      buildInputs = [ TestRequires ];
      propagatedBuildInputs = [ ClassAccessorLite ModuleBuildPluggable ];
      meta = {
        description = "Generate ppport.h";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    LogMinimal = buildPerlModule {
      pname = "Log-Minimal";
      version = "0.19";
      src = fetchurl {
        url = "mirror://cpan/authors/id/K/KA/KAZEBURO/Log-Minimal-0.19.tar.gz";
        sha256 =
          "e44b59041e709b54df1053d3eac1412a0648d5305ef3b4cd39590a721e525f68";
      };
      meta = {
        homepage = "https://github.com/kazeburo/Log-Minimal";
        description = "Minimal but customizable logger";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ClassAccessorLite = buildPerlPackage {
      pname = "Class-Accessor-Lite";
      version = "0.08";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZUHO/Class-Accessor-Lite-0.08.tar.gz";
        sha256 =
          "75b3b8ec8efe687677b63f0a10eef966e01f60735c56656ce75cbb44caba335a";
      };
      meta = {
        description = "A minimalistic variant of Class::Accessor";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ModuleLoad = buildPerlPackage {
      pname = "Module-Load";
      version = "0.36";
      src = fetchurl {
        url = "mirror://cpan/authors/id/B/BI/BINGOS/Module-Load-0.36.tar.gz";
        sha256 =
          "d825020ac00b220e89f9524e24d838f9438b072fcae8c91938e4026677bef6e0";
      };
      meta = {
        description = "Load modules in a DWIM style";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    BHooksOPCheck = buildPerlPackage {
      pname = "B-Hooks-OP-Check";
      version = "0.22";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/E/ET/ETHER/B-Hooks-OP-Check-0.22.tar.gz";
        sha256 =
          "c7b5d1bef59ef9087ff67eb3168d2624be94ae5464469e259ad11bfb8ad8cdcd";
      };
      buildInputs = [ ExtUtilsDepends ];
      meta = {
        homepage = "https://github.com/karenetheridge/B-Hooks-OP-Check";
        description = "Wrap OP check callbacks";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ModuleBuildPluggable = buildPerlModule {
      pname = "Module-Build-Pluggable";
      version = "0.10";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/T/TO/TOKUHIROM/Module-Build-Pluggable-0.10.tar.gz";
        sha256 =
          "e5bb2acb117792c984628812acb0fec376cb970caee8ede57535e04d762b0e40";
      };
      propagatedBuildInputs =
        [ ClassAccessorLite ClassMethodModifiers DataOptList TestSharedFork ];
      meta = {
        homepage = "https://github.com/tokuhirom/Module-Build-Pluggable";
        description = "Module::Build meets plugins";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    Appwatcher = buildPerlModule {
      pname = "App-watcher";
      version = "0.13";
      src = fetchurl {
        url = "mirror://cpan/authors/id/T/TO/TOKUHIROM/App-watcher-0.13.tar.gz";
        sha256 =
          "e0d5ab7ea586ebbc426e78f836d0614f9b8a216d5704ad2fb26e8773ef1f9512";
      };
      buildInputs = [ ModuleBuildTiny ];
      propagatedBuildInputs = [ FilesysNotifySimple ];
      meta = {
        homepage = "https://github.com/tokuhirom/App-watcher";
        description = "Watch the file updates";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    HTTPTiny = buildPerlPackage {
      pname = "HTTP-Tiny";
      version = "0.082";
      src = fetchurl {
        url = "mirror://cpan/authors/id/D/DA/DAGOLDEN/HTTP-Tiny-0.082.tar.gz";
        sha256 =
          "54e9e4a559a92cbb90e3f19c8a88ff067ec2f68fbe39bbb694ee70828cd5f4b8";
      };
      meta = {
        homepage = "https://github.com/chansen/p5-http-tiny";
        description = "A small, simple, correct HTTP/1.1 client";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ParallelScoreboard = buildPerlPackage {
      pname = "Parallel-Scoreboard";
      version = "0.08";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZUHO/Parallel-Scoreboard-0.08.tar.gz";
        sha256 =
          "d0b0718e0840bd8ab0c9aac2ea8cafc98de68a67aebb7bc267a5d5b1d2b95951";
      };
      propagatedBuildInputs = [ ClassAccessorLite HTMLParser JSON SubUplevel ];
      meta = {
        description = "A scoreboard for monitoring status of many workers";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ClassMethodModifiers = buildPerlPackage {
      pname = "Class-Method-Modifiers";
      version = "2.13";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/E/ET/ETHER/Class-Method-Modifiers-2.13.tar.gz";
        sha256 =
          "ab5807f71018a842de6b7a4826d6c1f24b8d5b09fcce5005a3309cf6ea40fd63";
      };
      buildInputs = [ TestFatal TestNeeds ];
      meta = {
        homepage = "https://github.com/moose/Class-Method-Modifiers";
        description = "Provides Moose-like method modifiers";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    PlackMiddlewareDirIndex = buildPerlPackage {
      pname = "Plack-Middleware-DirIndex";
      version = "1.01";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/D/DA/DAVECROSS/Plack-Middleware-DirIndex-1.01.tar.gz";
        sha256 =
          "cb12eb9cbc079ada8908be7eb3508b2625e1596035e7e6ec58e5df6ca5c7413d";
      };
      propagatedBuildInputs = [ Plack ];
      meta = {
        description = "Append an index file to request PATH's ending with a /";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
  };
in with modules; [
  Appwatcher
  CaptureTiny
  Carp
  ClassAccessorLite
  ClassMethodModifiers
  CommonMark
  CwdGuard
  DataOptList
  DataValidator
  DevelCheckCompiler
  Encode
  EncodeDetect
  EncodeLocale
  ExporterTiny
  ExtUtilsConfig
  ExtUtilsHelpers
  ExtUtilsInstallPaths
  FileCopyRecursiveReduced
  FileWhich
  Filepushd
  FilesysNotifySimple
  GetoptCompactWithCmd
  HTML5DOM
  HTMLEscape
  HTMLParser
  HTMLTagset
  HTTPDate
  HTTPMessage
  HTTPTiny
  HTTPTinyish
  IOHTML
  IPCRun3
  IPCSignal
  ImageScale
  Importer
  JSON
  JSONTiny
  LWPMediaTypes
  ListMoreUtils
  ListMoreUtilsXS
  LogMinimal
  MockConfig
  ModuleBuild
  ModuleBuildPluggable
  ModuleBuildPluggablePPPort
  ModuleBuildTiny
  ModuleCPANfile
  ModuleLoad
  ModulePluggable
  Mouse
  ParallelForkBossWorkerAsync
  ParallelPrefork
  ParallelScoreboard
  ParamsUtil
  PathTiny
  Plack
  PlackMiddlewareDirIndex
  ProcWait3
  Proclet
  ScopeGuard
  SetCrontab
  SignalMask
  StringShellQuote
  SubInfo
  SubInstall
  SubUplevel
  TermTable
  Test2Suite
  TestFatal
  TestLeakTrace
  TestNeeds
  TestNumberDelta
  TestOutput
  TestRequires
  TestSharedFork
  TestWarn
  TextAligner
  TextTable
  TimeCrontab
  TimeMoment
  TimeDate
  TryTiny
  URI
  XMLLibXML
  YAMLLibYAML
  YAMLTiny
]
