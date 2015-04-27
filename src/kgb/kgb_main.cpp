/**
 * @file kgb_main.cpp
 * @date Apr 25, 2015
 *
 * @author Milos Subotic <milos.subotic.sm@gmail.com>
 * @license GPLv2
 *
 * @brief KGB archiver command line interface.
 *
 * @version 1.0
 * Changelog:
 * 1.0 - Initial version.
 *
 */

///////////////////////////////////////////////////////////////////////////////

#include <cstdio>
#include <vector>
#include <string>
#include <cstring>

#include "kgb.h"

using namespace std;

///////////////////////////////////////////////////////////////////////////////

// Read and return a line of input from FILE f (default stdin) up to
// first control character except tab.  Skips CR in CR LF.
static string getline(FILE* f=stdin) {
  int c;
  string result="";
  while ((c=getc(f))!=EOF && (c>=32 || c=='\t'))
    result+=char(c);
  if (c=='\r')
    (void) getc(f);
  return result;
}

// User interface
int main(int argc, char** argv) {

  // Check arguments
  if (argc<2) {
      printf("KGB Archiver v1.0, (C) 2005-2006 Tomasz Pawlak\n"
      "Based on PAQ6 by Matt Mahoney\nmod by Slawek (poczta-sn@gazeta.pl)\n"
      "hacked by Micuri (milos.subotic.sm@gmail.com)\n\n"
      "Compression:\t\tkgb -<m> archive.kgb files <@list_files>\n"
      "Decompression:\t\tkgb archive.kgb\n"
      "Table of contests:\tmore < archive.kgb\n\n"
      "m argument\tmemory usage\n"
      "----------\t------------------------------\n"
      " -0       \t 2 MB (the fastest compression)\n"
      " -1       \t 3 MB\n"
      " -2       \t 6 MB\n"
      " -3       \t 18 MB (dafault)\n"
      " -4       \t 64 MB\n"
      " -5       \t 154 MB\n"
      " -6       \t 202 MB\n"
      " -7       \t 404 MB\n"
      " -8       \t 808 MB\n"
      " -9       \t 1616 MB (the best compression)\n");
    return 1;
  }

	int mem = 3;
  // Read and remove -MEM option
  if (argc>1 && argv[1][0]=='-') {
    if (isdigit(argv[1][1]) && argv[1][2]==0) {
      mem=argv[1][1]-'0';
    }
    else
      printf("Option %s ignored\n", argv[1]);
    argc--;
    argv++;
  }


  // Extract files
  FILE* archive=fopen(argv[1], "rb");
  if (archive) {
    if (argc>2) {
      printf("File %s already exists\n", argv[1]);
      return 1;
    }

	int ret = kgb_extract(archive, argv[1], NULL);
    fclose(archive);
	return ret;

  }

  // Compress files
  else {

    archive=fopen(argv[1], "wb");
    if (!archive) {
      printf("Cannot create archive: %s\n", argv[1]);
      return 1;
    }


	int ret;
    // Read file names from command line, input or @file with list of files
    if(argc > 2){
		ret = kgb_compress(
			archive,
			argv[1],
			mem,
			const_cast<const char**>(argv+2)
		);
    }else{
		vector<string> filename;
      printf(
        "Type filenames to compression, finish empty line:\n");
      while (true) {
        string s=getline(stdin);
        if (s=="")
          break;
        else
          filename.push_back(s);
      }
		// TODO kgb_compress
    }

    fclose(archive);

	return ret;
  }


  return 0;
}

///////////////////////////////////////////////////////////////////////////////

