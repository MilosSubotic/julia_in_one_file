/**
 * @file julia_in_one_file.cpp
 * @date Sep 14, 2014
 *
 * @author Milos Subotic <milos.subotic.sm@gmail.com>
 * @license MIT
 *
 * @brief Julia in one file.
 *
 * @version 2.1
 * Changelog:
 * 1.0 - Initial version.
 * 2.1 - Using JUnzip.
 *
 */

///////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include <stdint.h>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <cerrno>
#include <sys/stat.h>
#include <unistd.h>

#include "junzip.h"

using namespace std;

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
	

		static std::string join(const std::string& s0, const std::string& s1) {
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

		static std::string normpath(const std::string& s) {
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
		
		static std::string dirname(const std::string& s){
			size_t found = s.find_last_of('/');
			// Slash not found
			if(found == std::string::npos){
				return std::string();
			}else{
				return s.substr(0, found);
			}
		}
	} // namespace path
} // namespace os

static string path_join(const string& s0, const string& s1) {
	return os::path::normpath(os::path::join(s0, s1));
}
using os::path::dirname;

///////////////////////////////////////////////////////////////////////////////
// Zip stuff.

static string unpack_dir;
static vector<uint8_t> data;

static int record_callback(
	FILE* zip,
	long zip_start,
	long zip_end,
	int index,
	JZGlobalFileHeader* global_header,
	char* global_file_name
) {

	long offset = ftell(zip); // Save current position.

	if(
		fseek(
			zip, 
			zip_start + global_header->relativeOffsetOflocalHeader, 
			SEEK_SET
		)
	){
		printf("Cannot seek in zip file!");
		return 0; // abort
	}

	// Process file.
	JZFileHeader local_header;
	char file_name[1024];

	if(
		jzReadLocalFileHeader(
			zip, 
			&local_header, 
			file_name,
			sizeof(file_name)
		)
	){
		printf("Couldn't read local file header!");
		return -1;
	}

	string full_file_name = path_join(unpack_dir, file_name);
	if(local_header.uncompressedSize == 0){
		// Make dir.	


		int ret = mkdir(full_file_name.c_str(), 0755);
		if(ret && errno != EEXIST){
			cerr 
				<< "julia_in_one_file: Couldn't create directory \"" 
				<< full_file_name << "\"!" << endl;
		}
	}else{
		// Extract file.

		data.resize(local_header.uncompressedSize);

		if(jzReadData(zip, &local_header, data.data())) {
			cerr << "julia_in_one_file: Couldn't read file data!" << endl;
			return -1;
		}

		ofstream of(full_file_name.c_str(), ios::out | ios::binary);
		if(!of.is_open()){
			cerr 
				<< "julia_in_one_file: Cannot create file \""
				<< full_file_name << "\"!" << endl;
		}else{
			of.write(reinterpret_cast<const char*>(data.data()), data.size());
			of.close();

			mode_t mode = global_header->externalFileAttributes >> 16 & 07777;
			if(chmod(full_file_name.c_str(), mode)){
				cerr 
					<< "julia_in_one_file: Cannot chmod file \""
					<< full_file_name << "\"!" << endl;
			}

		}
	}

	fseek(zip, offset, SEEK_SET); // Restore position.

	return 1; // continue
};

static bool unpack_zip(
	FILE* zip,
	long zip_start,
	long zip_end,
	string unpack_dir_
) {
	unpack_dir = unpack_dir_;

	JZEndRecord end_record;

	if(jzReadEndRecord(zip, zip_start, zip_end, &end_record)){
		cerr << "Couldn't read ZIP file end record!" << endl;;
		return false;
	}

	if(
		jzReadCentralDirectory(
			zip,
			zip_start,
			zip_end,
			&end_record,
			record_callback
		)
	){
		cerr << "Couldn't read ZIP file central record!" << endl;
		return false;
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////

int main(int argc, char** argv) {

	if(argv[1] && (!strcmp(argv[1], "--version") || !strcmp(argv[1], "-v"))){
		// TODO Print julia_in_one_file version stuff.
	}
	
	string output_dir;
#ifdef WIN32
	output_dir = "C:";
	const char* env = getenv("LOCALAPPDATA");
	if(env){
		output_dir = path_join(env, "Temp");
	}
#else
	output_dir = "/tmp";
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
			string result = "";
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

		FILE* elf_and_zip = fopen(elf_path, "rb");
		if(!elf_and_zip){
			cerr 
				<< "julia_in_one_file: Cannot find my own ELF/EXE file!" 
				<< endl;
			return 1;
		}

		fseek(elf_and_zip, -8, SEEK_END);
		uint32_t root_start;
		fread(&root_start, 4, 1, elf_and_zip);
		uint32_t site_start;
		fread(&site_start, 4, 1, elf_and_zip);
		uint32_t root_end = site_start;
		uint32_t site_end = ftell(elf_and_zip);


		cout 
			<< "julia_in_one_file: Unpacking Julia to \"" 
			<< output_dir << "\"..." << endl;


		if(
			!unpack_zip(
				elf_and_zip,
				root_start,
				root_end,
				output_dir
			)
		){
			cerr 
				<< "julia_in_one_file: Error while unpacking Julia root to \"" 
				<< output_dir << "\"!" << endl;
			return 1;
		}


		string dir = path_join(output_dir, "julia_root/share/julia");
		if(
			!unpack_zip(
				elf_and_zip,
				site_start,
				site_end,
				dir
			)
		){
			cerr 
				<< "julia_in_one_file: Error while unpacking Julia site to \"" 
				<< dir << "\"!" << endl;
			return 1;
		}

		// Make status file after succesfull unpacking.
		ofstream sf(status_file.c_str());
		if(!sf.is_open()){
			cerr 
				<< "julia_in_one_file: Cannot open status file \""
				<< status_file << "\"!" << endl;
			return 1;
		}

		sf << "Julia succesfully unpacked!" << endl;
		sf.close();

		cout << "julia_in_one_file: Julia succesfully unpacked!" << endl;
	}

#ifdef WIN32
	string julia_elf = path_join(output_dir, "julia_root/bin/julia.exe");
#else
	string julia_elf = path_join(output_dir, "julia_root/bin/julia");
#endif

#if 0
	ostringstream oss;
	oss << julia_elf;
	// Start from 1 to skip program name.
	for(int i = 1; i < argc; i++){
		oss << " " << argv[i];
	}
	
	return system(oss.str().c_str());
#else
	argv[0] = new char(julia_elf.size());
	strcpy(argv[0], julia_elf.c_str());
	if(execv(julia_elf.c_str(), argv)){
		cerr 
			<< "julia_in_one_file: Cannot exec julia file \""
			<< julia_elf << "\"!" << endl;
		return 1;
	}

	return 0;
#endif
}

///////////////////////////////////////////////////////////////////////////////

