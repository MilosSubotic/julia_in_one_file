/**
 * @file julia_in_one_file.cpp
 * @date Sep 14, 2014
 *
 * @author Milos Subotic <milos.subotic.sm@gmail.com>
 * @license MIT
 *
 * @brief Julia in one file.
 *
 * @version 1.0
 * Changelog:
 * 1.0 - Initial version.
 *
 */

///////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <sstream>
#include <stdint.h>
#include <cstdlib>
#include <cmath>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
using namespace std;

///////////////////////////////////////////////////////////////////////////////
// User configuration.

#define OUTPUT_DIR "/tmp"
#define BLOCK_SIZE 4096

///////////////////////////////////////////////////////////////////////////////

// Initialized with magic number, so it could be changed by script.
volatile uint32_t tarball_offset = 0xdeadbeef;

int main(int argc, char** argv) {

	string s = OUTPUT_DIR;
	s += "/julia_root/.status";
	const char* status_file = s.c_str();

	// If there is no status file unpack julia.
	if(access(status_file, R_OK)){

		// Get julia_in_one_file (ELF + tarball) full path.
		string which_cmd;
#if defined(WIN32)
		which_cmd += "where ";
#else
		which_cmd += "which ";
#endif
		which_cmd += argv[0];

		FILE* pipe = popen(which_cmd.c_str(), "r");
		if(!pipe){
			cout << "julia_in_one_file: Cannot get executable path!" << endl;
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
			cout << "julia_in_one_file: Cannot get executable path!" << endl;
			return 1;
		}

		// Remove \n at the end.
		result.erase(result.find('\n'));

		const char* elf_path = result.c_str();


		// Get sizes calculated.
		struct stat st;
		stat(elf_path, &st);
		uint32_t elf_size = st.st_size;

		uint32_t tarball_size = elf_size - tarball_offset;

		uint32_t tarball_offset_in_blocks = tarball_offset / BLOCK_SIZE;
		uint32_t tarball_size_in_blocks = ceil(double(tarball_size) / BLOCK_SIZE);

		ostringstream oss;
		oss << "rm -rf " << OUTPUT_DIR << "/julia_root && "
			<< "dd bs=" << BLOCK_SIZE
			<< " count=" << tarball_size_in_blocks
			<< " skip=" << tarball_offset_in_blocks
			<< " if=" << elf_path << " | "
			<< "tar xfvj - -C " << OUTPUT_DIR;
	
		cout << "julia_in_one_file: Unpacking Julia to \"" 
			<< OUTPUT_DIR << "\"..." << endl;

		int ret = system(oss.str().c_str());
		if(ret){
			cerr << "julia_in_one_file: Error while unpacking Julia to \"" 
				<< OUTPUT_DIR << "\"!" << endl;
			return 1;
		}

		// Make status file after succesfull unpacking.
		ofstream sf(status_file);
		if(!sf.is_open()){
			cerr << "julia_in_one_file: Cannot open status file \"" 
				<< status_file << "\"!" << endl;
			return 1;
		}
		
		sf << "Julia succesfully unpacked!" << endl;
		sf.close();

		cout << "julia_in_one_file: Julia succesfully unpacked!" << endl;
	}

	string j = OUTPUT_DIR;
	j += "/julia_root/bin/julia";
	const char* julia = j.c_str();

	if(execvp(julia, argv)){
		cout << "julia_in_one_file: Error while executing \"" 
			<< julia << "\"! errno = " << errno << endl;
		return 1;
	}

	return 0;
}

///////////////////////////////////////////////////////////////////////////////

