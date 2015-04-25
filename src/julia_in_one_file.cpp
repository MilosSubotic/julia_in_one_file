/**
 * @file julia_in_one_file.cpp
 * @date Sep 14, 2014
 *
 * @author Milos Subotic <milos.subotic.sm@gmail.com>
 * @license MIT
 *
 * @brief Julia in one file.
 *
 * @version 2.0
 * Changelog:
 * 1.0 - Initial version.
 * 2.0 - Using KGB.
 *
 */

///////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <stdint.h>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

#include "kgb.h"

using namespace std;

///////////////////////////////////////////////////////////////////////////////
// User configuration.

#ifdef WIN32
#define DEFAULT_OUTPUT_DIR "C:"
#else
#define DEFAULT_OUTPUT_DIR "/tmp"
#endif
#define BLOCK_SIZE 4096

///////////////////////////////////////////////////////////////////////////////
// Path stuff.

namespace os {
	namespace path {

#ifdef WIN32
		const char pathsep =  '\\';
		const char other_pathsep =  '/';
#else
		const char pathsep =  '/';
		const char other_pathsep =  '\\';
#endif
	

		std::string join(const std::string& s0, const std::string& s1) {
			std::string r(s0);
			if(!r.empty()){
				// Last char is not /?
				if(*(r.end()-1) != pathsep){
					// Add it.
					r += pathsep;
				}
			}
			r += s1;
			return r;
		}

		static bool doubleSlash(char a, char b){
			return a == pathsep && b == pathsep;
		}

		std::string normpath(const std::string& s) {
			std::string r(s);

			// A\B to A/B
			replace(r.begin(), r.end(), other_pathsep, pathsep);

			// A//B to A/B
			r.erase(
				std::unique(r.begin(), r.end(), doubleSlash),
				r.end()
			);

			// A/B/ to A/B
			if(!r.empty()){
				// Last char is /?
				if(*(r.end()-1) == '/'){
					// Erase it.
					r.erase(r.size() - 1);
				}
			}

			// TODO  A/foo/../B to A/B
			return r;
		}
		
	} // namespace path
} // namespace os

///////////////////////////////////////////////////////////////////////////////

std::string path_join(const std::string& s0, const std::string& s1) {
	return os::path::normpath(os::path::join(s0, s1));
}

int main(int argc, char** argv) {

	if(argv[1] && (!strcmp(argv[1], "--version") || !strcmp(argv[1], "-v"))){
		// TODO Print julia_in_one_file version stuff.
	}

	string output_dir = DEFAULT_OUTPUT_DIR;
	
#ifdef WIN32
	const char* env = getenv("LOCALAPPDATA");
	if(env){
		output_dir = path_join(env, "Temp");
	}
#endif

	string status_file = path_join(output_dir, "julia_root/.status");
	
	// If there is no status file unpack julia.
	if(access(status_file.c_str(), R_OK)){
		const char* elf_path;

#ifdef WIN32
		if(isalpha(argv[0][0]) && argv[0][1] == ':' && argv[0][2] == '\\') {
#else
		if(argv[0][0] == '/') {
#endif
			elf_path = argv[0];
		}else{
			// Get julia_in_one_file (ELF + tarball) full path.
			string which_cmd;
#ifdef WIN32
			which_cmd += "where ";
#else
			which_cmd += "which ";
#endif
			which_cmd += argv[0];

			FILE* pipe = popen(which_cmd.c_str(), "r");
			if(!pipe){
				cout << "julia_in_one_file: Cannot get executable path!" 
					<< endl;
				return 1;
			}
			char buffer[128];
			std::string result = "";
			while(!feof(pipe)) {
				if(fgets(buffer, 128, pipe) != NULL)
					result += buffer;
			}
			pclose(pipe);
			// Remove \n at the end.
			if(result == ""){
				cout << "julia_in_one_file: Cannot get executable path!" 
					<< endl;
				return 1;
			}

			// Remove \n at the end.
			result.erase(result.find('\n'));

			elf_path = result.c_str();
		}

		FILE* elf_file = fopen(elf_path, "rb");
		fseek(elf_file, -4, SEEK_END);
		uint32_t kgb_archive_pos;
		fread(&kgb_archive_pos, 4, 1, elf_file);
		cout << "kgb_archive_pos = " << kgb_archive_pos << endl;

		return 0;

		ostringstream oss;

	
		cout << "julia_in_one_file: Unpacking Julia to \"" 
			<< output_dir << "\"..." << endl;

		int ret = system(oss.str().c_str());
		if(ret){
			cerr << "julia_in_one_file: Error while unpacking Julia to \"" 
				<< output_dir << "\"!" << endl;
			return 1;
		}

		// Make status file after succesfull unpacking.
		ofstream sf(status_file.c_str());
		if(!sf.is_open()){
			cerr << "julia_in_one_file: Cannot open status file \""
					<< status_file << "\"!" << endl;
				return 1;
		}

		sf << "Julia succesfully unpacked!" << endl;
		sf.close();

		cout << "julia_in_one_file: Julia succesfully unpacked!" << endl;
	}

	ostringstream oss;
	oss << path_join(output_dir, "/julia_root/bin/julia");
#ifdef WIN32
	oss << ".exe";
#endif

	// Skip program name.
	for(int i = 1; i < argc; i++){
		oss << " " << argv[i] << " ";
	}
	
	return system(oss.str().c_str());
}

///////////////////////////////////////////////////////////////////////////////

