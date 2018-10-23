import 'dart:io';
import 'dart:async';
import 'dart:convert';

Future getRepo() async {
  var repofile = File("/etc/hubbit/repos.json");
  try {
    var contents = await repofile.readAsString();
    var parsed = jsonDecode(contents);
    return parsed;
  } catch(e) {
    print("Unable to read repositiory.");
  }
}

Future install(String name) async {
  var repo = await getRepo();
  if(repo.containsKey(name)) {
    print("▍ \u001b[37;1mPackage '$name' found in repository '${repo[name]["repo"]}'\u001b[0m");
    print("▍ Installed size:  ${repo[name]["installedSize"]}");
    print("▍ Download size:   ${repo[name]["size"]}");
    stdout.write("▍ \u001b[37;1mEnter to continue, ^C to cancel\u001b[0m ");
    String yesno = stdin.readLineSync();
    print("\n\u001b[32mflatpak install ${repo[name]["repo"]} ${repo[name]["name"]} -y\u001b[0m");
    
    var installProcess = await Process.start(
      'echo', 
      ["install", 
        repo[name]["repo"], 
        repo[name]["name"],
        "--assumeyes"
      ],
      runInShell: true);
    stdin.pipe(installProcess.stdin);
    installProcess.stdout.pipe(stdout);
  } else {
    print("Error: Package not found: \u001b[31m$name\u001b[0m");
  };
}


Future mainFunc(args) async {
  if(args.length < 2) {
    print("Expected 2 arguments, got ${args.length}");
  } else {
    if(args[0].contains("install")) {
      install(args[1]);
    }
  }
}

Future main(args) async {
  Process.run('whoami', []).then((result) {
    if(result.stdout.contains("root")) {
      return mainFunc(args);
    } else {
      print("This command must be run as root.");
    }
  });
}