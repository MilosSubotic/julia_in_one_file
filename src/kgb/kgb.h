/**
 * @file kgb.h
 * @date Apr 7, 2015
 *
 * @author Milos Subotic <milos.subotic.sm@gmail.com>
 * @license GPLv2
 *
 * @brief KGB archiver library API.
 *
 * @version 1.0
 * Changelog:
 * 1.0 - Initial version.
 *
 */

#ifndef KGB_H_
#define KGB_H_

///////////////////////////////////////////////////////////////////////////////

#include <cstdio>

///////////////////////////////////////////////////////////////////////////////

int kgb_compress(
	FILE* archive,
	const char* archive_filename,
	int mem,
	const char** args
);

int kgb_extract(
	FILE* archive, 
	const char* archive_filename
);

///////////////////////////////////////////////////////////////////////////////

#endif // KGB_H_

