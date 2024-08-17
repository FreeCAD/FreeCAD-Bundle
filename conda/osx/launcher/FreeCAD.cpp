#include <cstdlib>
#include <iostream>
#include <map>
#include <vector>

#include <libgen.h>
#include <unistd.h>

#if defined(__arm64__)
    #define ARCH "osx-arm64"
#else
    #define ARCH "osx-64"
#endif

int main(int argc, char *argv[], char *const *envp) {
    char *cwd = dirname(realpath(argv[0], NULL));

    std::string FreeCAD = std::string(cwd) + "/../Resources/" + ARCH + "/bin/FreeCAD";

    std::map<std::string, std::string> env;
    for(int i = 0; envp[i] != NULL; ++i) {
        std::string e(envp[i]);
        auto sep = e.find('=');
        auto var = e.substr(0, sep);
        auto value = e.substr(sep+1, std::string::npos);
        env[var] = value;
    }

    env["PREFIX"]               = std::string(cwd) + "/Resources/" + ARCH;
    env["LD_LIBRARY_PATH"]      = env["PREFIX"] + "/lib";
    env["PYTHONHOME"]           = env["PREFIX"];
    env["FONTCONFIG_FILE"]      = "/etc/fonts/fonts.conf";
    env["FONTCONFIG_PATH"]      = "/etc/fonts";
    env["LANG"]                 = "UTF-8";                              // https://forum.freecad.org/viewtopic.php?f=22&t=42644
    env["SSL_CERT_FILE"]        = env["PREFIX"] + "/ssl/cacert.pem";    // https://forum.freecad.org/viewtopic.php?f=3&t=42825
    env["GIT_SSL_CAINFO"]       = env["PREFIX"] + "/ssl/cacert.pem";
    env["QT_MAC_WANTS_LAYER"]   = "1";

    char **new_env = new char*[env.size() + 1];
    int i = 0;
    for (const auto& [var, value] : env) {
        auto line = var + '=' + value;
        new_env[i] = new char[line.length()];
        strncpy(new_env[i], line.c_str(), line.length());
        i++;
    }
    new_env[i] = NULL;

    // for(i = 0; i < env.size(); i++) {
    //     std::cout << new_env[i] << std::endl;
    // }

    std::cout << "Running: " << FreeCAD << std::endl;

    return execve(FreeCAD.c_str(), argv, new_env);
}
