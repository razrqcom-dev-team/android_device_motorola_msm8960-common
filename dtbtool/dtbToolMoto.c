/*
 * Copyright (C) 2015 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

/* Maximum padding, 4 bytes for "no DT at the end" */
const char padding[] = { 0, 0, 0, 0 };

void print_usage()
{
	printf("Usage: dtbToolMoto -o dt.img [input_dtbs]\n");
}

size_t copy_file(FILE* in, FILE* out)
{
	char buffer[4096];
	size_t bytes;
	size_t total = 0;

	while ((bytes = fread(buffer, 1, sizeof(buffer), in)) > 0)
	{
		total += bytes;
		fwrite(buffer, 1, bytes, out);
	}

	return total;
}

int main(int argc, char** argv)
{
	int i, no_dtbs = 0, next_is_output = 0;
	const char* output_image = NULL;
	const char* input_dtb[256];

	/* Check arguments */
	for (i = 1; i < argc && no_dtbs < 256; i++)
	{
		if (!strcmp(argv[i], "-o"))
		{
			if (output_image)
			{
				/* Attempt to make second output */
				print_usage();
				return 1;
			}

			next_is_output = 1;
			continue;
		}

		if (next_is_output)
		{
			output_image = argv[i];
			next_is_output = 0;
			continue;
		}

		input_dtb[no_dtbs] = argv[i];
		no_dtbs++;
	}

	/* Check valitidy */
	if (!no_dtbs || !output_image)
	{
		print_usage();
		return 1;
	}

	FILE* out_file = fopen(output_image, "wb+");
	if (!out_file)
	{
		fprintf(stderr, "Cannot open %s for writing!\n", output_image);
		return 1;
	}

	for (i = 0; i < no_dtbs; i++)
	{
		size_t file_size;
		size_t alignment;
		FILE* dtb_file = fopen(input_dtb[i], "rb");

		if (!dtb_file)
		{
			fclose(out_file);
			fprintf(stderr, "Cannot open %s for reading!\n", input_dtb[i]);
			return 1;
		}

		file_size = copy_file(dtb_file, out_file);
		alignment = file_size % 4;

		if (alignment)
			fwrite(padding, 1, 4 - alignment, out_file);

		fclose(dtb_file);
	}

	/* Write no DTB at the end */
	fwrite(padding, 1, 4, out_file);

	fclose(out_file);
	return 0;
}
