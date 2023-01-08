{ pkgs, ... }:
with pkgs;
with perlPackages;
let
  modules = rec {
    AlienBuildPluginDownloadGitLab = buildPerlPackage {
      pname = "Alien-Build-Plugin-Download-GitLab";
      version = "0.01";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/P/PL/PLICEASE/Alien-Build-Plugin-Download-GitLab-0.01.tar.gz";
        sha256 =
          "c1f089c8ea152a789909d48a83dbfcf2626f773daf30431c8622582b26aba902";
      };
      buildInputs = [ Test2Suite ];
      propagatedBuildInputs = [ AlienBuild PathTiny URI ];
      meta = {
        homepage =
          "https://metacpan.org/pod/Alien::Build::Plugin::Download::GitLab";
        description = "Alien::Build plugin to download from GitLab";
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
    DevelStackTraceAsHTML = buildPerlPackage {
      pname = "Devel-StackTrace-AsHTML";
      version = "0.15";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/M/MI/MIYAGAWA/Devel-StackTrace-AsHTML-0.15.tar.gz";
        sha256 =
          "6283dbe2197e2f20009cc4b449997742169cdd951bfc44cbc6e62c2a962d3147";
      };
      propagatedBuildInputs = [ DevelStackTrace ];
      meta = {
        homepage = "https://github.com/miyagawa/Devel-StackTrace-AsHTML";
        description = "Displays stack trace in HTML";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
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
    FileShareDirInstall = buildPerlPackage {
      pname = "File-ShareDir-Install";
      version = "0.14";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/E/ET/ETHER/File-ShareDir-Install-0.14.tar.gz";
        sha256 =
          "8f9533b198f2d4a9a5288cbc7d224f7679ad05a7a8573745599789428bc5aea0";
      };
      meta = {
        homepage =
          "https://github.com/Perl-Toolchain-Gang/File-ShareDir-Install";
        description = "Install shared files";
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
    HTTPEntityParser = buildPerlModule {
      pname = "HTTP-Entity-Parser";
      version = "0.25";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZEBURO/HTTP-Entity-Parser-0.25.tar.gz";
        sha256 =
          "3a8cd0d8cba3d17cd8c04ee82d7341dfaa247dbdd94a49eb94b53f69e483ec3a";
      };
      buildInputs = [ HTTPMessage ModuleBuildTiny ];
      propagatedBuildInputs = [
        HTTPMultiPartParser
        HashMultiValue
        JSONMaybeXS
        StreamBuffered
        WWWFormUrlEncoded
      ];
      meta = {
        homepage = "https://github.com/kazeburo/HTTP-Entity-Parser";
        description = "PSGI compliant HTTP Entity Parser";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    HTTPHeadersFast = buildPerlModule {
      pname = "HTTP-Headers-Fast";
      version = "0.22";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/T/TO/TOKUHIROM/HTTP-Headers-Fast-0.22.tar.gz";
        sha256 =
          "cc431db68496dd884db4bc0c0b7112c1f4a4f1dc68c4f5a3caa757a1e7481b48";
      };
      buildInputs = [ ModuleBuildTiny TestRequires ];
      propagatedBuildInputs = [ HTTPDate ];
      meta = {
        homepage = "https://github.com/tokuhirom/HTTP-Headers-Fast";
        description = "Faster implementation of HTTP::Headers";
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
    ModuleBuildXSUtil = buildPerlModule {
      pname = "Module-Build-XSUtil";
      version = "0.19";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/H/HI/HIDEAKIO/Module-Build-XSUtil-0.19.tar.gz";
        sha256 =
          "9063b3c346edeb422807ffe49ffb23038c4f900d4a77b845ce4b53d97bf29400";
      };
      buildInputs = [ CaptureTiny CwdGuard FileCopyRecursiveReduced ];
      propagatedBuildInputs = [ DevelCheckCompiler ];
      meta = {
        homepage = "https://github.com/hideo55/Module-Build-XSUtil";
        description = "A Module::Build class for building XS modules";
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
    POSIXstrftimeCompiler = buildPerlModule {
      pname = "POSIX-strftime-Compiler";
      version = "0.44";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZEBURO/POSIX-strftime-Compiler-0.44.tar.gz";
        sha256 =
          "dfd3c97398dcfe51c8236b85e3dc28035667b76531f7aa0a6535f3aa5405b35a";
      };
      buildInputs = [ ModuleBuildTiny ];
      meta = {
        homepage = "https://github.com/kazeburo/POSIX-strftime-Compiler";
        description =
          "GNU C library compatible strftime for loggers and servers";
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
    TextHyperScript = buildPerlModule {
      pname = "Text-HyperScript";
      version = "0.05";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/N/NY/NYARLA/Text-HyperScript-0.05.tar.gz";
        sha256 =
          "e0a68f90decdd513f604752f6078fdf1fe254395fba9f39d539dbc10dc264820";
      };
      buildInputs = [ ModuleBuildTiny Test2Suite ];
      propagatedBuildInputs = [ ExporterLite ];
      meta = {
        homepage = "https://github.com/nyarla/p5-Text-HyperScript";
        description = "The HyperScript like library for Perl";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
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
    URIEncodeXS = buildPerlPackage {
      pname = "URI-Encode-XS";
      version = "0.11";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/D/DF/DFARRELL/URI-Encode-XS-0.11.tar.gz";
        sha256 =
          "2bc20e4d7c8163e82a865bcbb60918621ccf09c9c74b7b0aaa30efa1b103013f";
      };
      meta = {
        description = "A Perl URI encoder/decoder using C";
        license = lib.licenses.bsd2;
      };
    };
    URIFast = buildPerlPackage {
      pname = "URI-Fast";
      version = "0.55";
      src = fetchurl {
        url = "mirror://cpan/authors/id/J/JE/JEFFOBER/URI-Fast-0.55.tar.gz";
        sha256 =
          "427afaa0f4d2225a7d0bd78d890e226e7598f82d761fcc2d2d368575386eb7a9";
      };
      buildInputs =
        [ Test2Suite TestLeakTrace URI URIEncodeXS UnicodeLineBreak ];
      meta = {
        homepage = "https://github.com/sysread/URI-Fast";
        description = "A fast(er) URI parser";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    WWWFormUrlEncoded = buildPerlModule {
      pname = "WWW-Form-UrlEncoded";
      version = "0.26";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZEBURO/WWW-Form-UrlEncoded-0.26.tar.gz";
        sha256 =
          "c0480b5f1f15b71163ec327b8e7842298f0cb3ace97e63d7034af1e94a2d90f4";
      };
      meta = {
        homepage = "https://github.com/kazeburo/WWW-Form-UrlEncoded";
        description =
          "Parser and builder for application/x-www-form-urlencoded";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    XMLSAXBase = buildPerlPackage {
      pname = "XML-SAX-Base";
      version = "1.09";
      src = fetchurl {
        url = "mirror://cpan/authors/id/G/GR/GRANTM/XML-SAX-Base-1.09.tar.gz";
        sha256 =
          "66cb355ba4ef47c10ca738bd35999723644386ac853abbeb5132841f5e8a2ad0";
      };
      meta = {
        description = "Base class for SAX Drivers and Filters";
        license = with lib.licenses; [ artistic1 gpl1Plus ];
      };
    };
    ApacheLogFormatCompiler = buildPerlModule {
      pname = "Apache-LogFormat-Compiler";
      version = "0.36";
      src = fetchurl {
        url =
          "mirror://cpan/authors/id/K/KA/KAZEBURO/Apache-LogFormat-Compiler-0.36.tar.gz";
        sha256 =
          "94509503ee74ea820183d070c11630ee5bc0fd8c12cb74fae953ed62e4a1ac17";
      };
      buildInputs =
        [ HTTPMessage ModuleBuildTiny TestMockTime TestRequires TryTiny URI ];
      propagatedBuildInputs = [ POSIXstrftimeCompiler ];
      preCheck = ''
        rm t/04_tz.t
      '';
      meta = {
        homepage = "https://github.com/kazeburo/Apache-LogFormat-Compiler";
        description = "Compile a log format string to perl-code";
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
  };
in with modules; [
  AlgorithmDiff
  AlienBuild
  AlienBuildPluginDownloadGitLab
  AlienLibxml2
  ApacheLogFormatCompiler
  Appwatcher
  BCOW
  CaptureTiny
  Carp
  ClassAccessorLite
  ClassInspector
  Clone
  CommonMark
  CookieBaker
  CwdGuard
  DataValidator
  DevelCheckCompiler
  DevelNYTProf
  DevelStackTrace
  DevelStackTraceAsHTML
  Encode
  EncodeDetect
  EncodeLocale
  ExporterLite
  ExporterTiny
  ExtUtilsConfig
  ExtUtilsHelpers
  ExtUtilsInstallPaths
  FFICheckLib
  FileCopyRecursiveReduced
  FileShareDir
  FileShareDirInstall
  FileWhich
  Filechdir
  Filepushd
  FilesysNotifySimple
  GetoptCompactWithCmd
  HTML5DOM
  HTMLParser
  HTMLTagset
  HTTPDate
  HTTPEntityParser
  HTTPHeadersFast
  HTTPMessage
  HTTPMultiPartParser
  HTTPTiny
  HTTPTinyish
  HashMultiValue
  IOHTML
  IPCRun3
  IPCSignal
  Importer
  JSON
  JSONMaybeXS
  JSONXS
  LWPMediaTypes
  ListMoreUtils
  ListMoreUtilsXS
  LogMinimal
  MIMECharset
  MockConfig
  ModuleBuild
  ModuleBuildTiny
  ModuleBuildXSUtil
  ModuleCPANfile
  ModuleLoad
  ModulePluggable
  Mouse
  POSIXstrftimeCompiler
  ParallelForkBossWorkerAsync
  ParallelPrefork
  ParallelScoreboard
  PathTiny
  Plack
  PlackMiddlewareDirIndex
  PodParser
  ProcWait3
  Proclet
  ScopeGuard
  SetCrontab
  SignalMask
  StreamBuffered
  StringShellQuote
  SubInfo
  SubName
  SubUplevel
  TermTable
  Test2Suite
  TestDeep
  TestDifferences
  TestException
  TestFatal
  TestLeakTrace
  TestMockTime
  TestNeeds
  TestNumberDelta
  TestOutput
  TestRequires
  TestSharedFork
  TestTCP
  TestTime
  TestWarn
  TestWarnings
  TextAligner
  TextDiff
  TextHyperScript
  TextTable
  TimeCrontab
  TimeMoment
  TimeDate
  TryTiny
  URI
  URIEncodeXS
  URIFast
  UnicodeLineBreak
  WWWFormUrlEncoded
  XMLLibXML
  XMLNamespaceSupport
  XMLSAX
  XMLSAXBase
  YAMLLibYAML
]
