#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <inttypes.h>

#define MAXLINELENGTH 1000
#define MAXNUMLABELS 10000
#define MAXLABELLENGTH 16

#define OP_SHIFT 13
#define A_SHIFT  10
#define B_SHIFT  7

#define ADD  0
#define ADDI 1
#define NAND 2
#define LUI  3
#define SW   4
#define LW   5
#define BEQ  6
#define JALR 7
#define EXT  7	// EXTENDED overlapped with JALR

char * readAndParse(FILE *, char *, char **, char **, char **, char **, char **);
int isNumber(char *);

#define ntoi(str)	strtol(str, NULL, 0)

char Labels[MAXNUMLABELS][MAXLABELLENGTH];
short Addresses[MAXNUMLABELS];
short NumValidLabels=0;

#define MAX_ARGUMENTS	3
#define MAX_INSTYPES	3
char *formats[ MAX_INSTYPES ][ 16 ] = {
	{
		"three-operand",
		"three-operand",
		"three-operand",

		"add",
		"addi",
		"nand",
		"lw",
		"sw",
		"beq",
		NULL,
	},
	{
		"two-operand",
		"two-operand",
		NULL,

		"jalr"
		"lui",
		"lli",
		"movi",
		NULL,
	},
	{
		"one-operand",
		NULL,
		NULL,

		".fill",
		".space",
		"sys",
		"exc",
		NULL,
	},
};

enum extended_types {
		EXT_NONE,
		EXT_SYSCALL,
		EXT_MFSPR,
		EXT_MTSPR,
		EXT_RFU1,
		EXT_RFU2,
		EXT_RFU3,
		EXT_EXCEPTION,
};

enum exception_types {
		EXC_NONE,
		EXC_HALT,
		EXC_TLBMISS,
		EXC_SIGSEGV,
		EXC_INVALID,
};

short
get_label_address(s)
char *s;
{
	int i;

	for (i=0; i<NumValidLabels; i++) {
		if (strlen(Labels[i]) == 0) {
			return -1;
		}
		if (strcmp(Labels[i], s) == 0) {
			return Addresses[i];
		}
	}
	return -1;
}

short
reg(s)
char *s;
{
	int reg = atoi(s);

	if (!isNumber(s)) {
		if (s[0] == 'r' && isdigit(s[1])) {
			reg = atoi(s+1);
		} else {
			fprintf(stderr, "error: [%s] must be a register value\n", s);
			exit(0);
		}
	}
	if (reg < 0 || reg > 7) {
		fprintf(stderr, "error: register value [%s/%d] out of range\n", s, reg);
		exit(0);
	}
	return (short)(reg & 0x7);
}

short
imm(s)
char *s;
{
	short imm;

	/* if s is symbolic, then translate into an address */
	if (isNumber(s)) {
		imm = ntoi(s);
	} else {
		imm = get_label_address(s);
	}
	if (imm < -64 || imm > 63) {
		fprintf(stderr, "error: offset %hd out of range\n", imm);
		exit(1);
	}

	return imm & 0x7f;
}

short
raw(s)
char *s;
{
	short imm;

	/* if s is symbolic, then translate into an address */
	if (isNumber(s)) {
		imm = ntoi(s);
	} else {
		imm = get_label_address(s);
	}

	return imm;
}

int main(int argc, char *argv[])
{
	char *inFileString, *outFileString;
	FILE *inFilePtr, *outFilePtr;
	short address;
	char *label, *opcode, *arg0, *arg1, *arg2;
	//char *statusString;
	char lineString[MAXLINELENGTH+1];
	short i,j;
	short num;
	short immediateValue;

	if (argc != 3) {
		fprintf(stderr, "error: usage: %s <assembly-code-file> <machine-code-file> \n", argv[0]);
		exit(1);
	}

	inFileString = argv[1];
	outFileString = argv[2];

	inFilePtr = fopen(inFileString, "r");
	if (inFilePtr == NULL) {
		fprintf(stderr, "error in opening %s\n", inFileString);
		exit(1);
	}
	outFilePtr = fopen(outFileString, "w");
	if (outFilePtr == NULL) {
		fprintf(stderr, "error in opening %s\n", outFileString);
		exit(1);
	}

	/* PASS ONE -- map symbols to addresses */

	/* assume address start at 0 */
	address = 0;

	while(readAndParse(inFilePtr, lineString, &label, &opcode, &arg0, &arg1, &arg2) != NULL) {

		for (i=0; i<MAX_INSTYPES; i++) {
			for (j=MAX_ARGUMENTS; formats[i][j] != NULL; j++) {
				if (strcmp(opcode, formats[i][j]) == 0 &&
				    ((formats[i][0] != NULL && arg0 == NULL) ||
					 (formats[i][1] != NULL && arg1 == NULL) ||
					 (formats[i][2] != NULL && arg2 == NULL))) {

					fprintf(stderr, "error at address %hd: too few args (%s is a %s instruction)\n",
						address, opcode, formats[i][0]);
					exit(1);
				}
			}
		}

		if (label != NULL) {
			/* look for duplicate label */
			if ((i = get_label_address(label)) < 0) {
				/* label not found -- a good sign */
				/* but first -- make sure we don't overrun buffer */
				if (NumValidLabels >= MAXNUMLABELS) {
					/* we will exceed the size of the array */
					fprintf(stderr, "error: too many labels (label=%s)\n", label);
					exit(1);
				}
				if (strlen(label) >= MAXLABELLENGTH) {
					/* we will exceed the size of the label storage */
					fprintf(stderr, "error: label [%s] too long (max: %d chars)\n", label, MAXLABELLENGTH-1);
					exit(1);
				}
				strcpy(Labels[NumValidLabels], label);
				Addresses[NumValidLabels] = address;
				NumValidLabels++;
			} else {
				/* duplicate label -- terminate */
				fprintf(stderr, "error: duplicate label %s \n", label);
				exit(1);
			}
		}

		if (!strcmp(opcode, "movi")) {
			address+=2;
		} else if (!strcmp(opcode, ".space")) {
			if (isNumber(arg0)) {
				address += ntoi(arg0);
			} else {
				fprintf(stderr, "error: .space needs integer argument\n");
				exit(1);
			}
		} else {
			address++;
		}
	}

	/* PASS TWO -- print machine code, with symbols filled in as addresses */

	rewind(inFilePtr);
	address = 0;

	while(readAndParse(inFilePtr, lineString, &label, &opcode, &arg0, &arg1, &arg2) != NULL) {

		if (!strcmp(opcode, "add")) {
			num = (ADD << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | reg(arg2);

		} else if (!strcmp(opcode, "addi")) {
			num = (ADDI << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | imm(arg2);

		} else if (!strcmp(opcode, "nand")) {
			num = (NAND << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | reg(arg2);

		} else if (!strcmp(opcode, "lui")) {
			num = (LUI << OP_SHIFT) | (reg(arg0) << A_SHIFT) | ((raw(arg1)) & 0x3ff);

		} else if (!strcmp(opcode, "lw")) {
			num = (LW << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | imm(arg2);

		} else if (!strcmp(opcode, "sw")) {
			num = (SW << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | imm(arg2);

		} else if (!strcmp(opcode, "jalr")) {
			num = (JALR << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT);

		} else if (!strcmp(opcode, "beq")) {
			/* if arg2 is symbolic, then translate into an address */
			if (isNumber(arg2)) {
				immediateValue = ntoi(arg2);
			} else {
				immediateValue = get_label_address(arg2) - address - 1;
			}
			if (immediateValue < -64 || immediateValue > 63) {
				fprintf(stderr, "error: offset %hd out of range\n", immediateValue);
				exit(1);
			}
			num = (BEQ << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg1) << B_SHIFT) | (immediateValue & 0x7f);

		} else if (!strcmp(opcode, "nop")) {
			num = (ADD << OP_SHIFT) | (reg("0") << A_SHIFT) | (reg("0") << B_SHIFT) | reg("0");

		} else if (!strcmp(opcode, "halt")) {
			num = (EXT << OP_SHIFT) | (reg("0") << A_SHIFT) | (reg("0") << B_SHIFT) | (EXT_EXCEPTION << 4) | EXC_HALT;

		} else if (!strcmp(opcode, "sys")) {
			num = (EXT << OP_SHIFT) | (reg("0") << A_SHIFT) | (reg("0") << B_SHIFT) | (EXT_SYSCALL << 4) | (raw(arg0) & 0xf);

		} else if (!strcmp(opcode, "exc")) {
			num = (EXT << OP_SHIFT) | (reg("0") << A_SHIFT) | (reg("0") << B_SHIFT) | (EXT_EXCEPTION << 4) | (raw(arg0) & 0xf);

		} else if (!strcmp(opcode, "lli")) {
			num = (ADDI << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg0) << B_SHIFT) | (raw(arg1) & 0x3f);

		} else if (!strcmp(opcode, "movi")) {
			num = (LUI << OP_SHIFT) | (reg(arg0) << A_SHIFT) | ((raw(arg1) >> 6) & 0x3ff);
			fprintf(outFilePtr, "%04hx\n", num);
			address++;
			num = (ADDI << OP_SHIFT) | (reg(arg0) << A_SHIFT) | (reg(arg0) << B_SHIFT) | (raw(arg1) & 0x3f);

		} else if (!strcmp(opcode, ".fill")) {
			num = raw(arg0);

		} else if (!strcmp(opcode, ".space")) {
			i = raw(arg0); 
			num = 0;
			if (i > 1) {
				for ( ; i>1; i--) {
					fprintf(outFilePtr, "%04hx\n", num);
					address++;
				}
			} else if (i <= 0) {
				fprintf(stderr, "error: argument %hd out of range for .space\n", i);
				exit(1);
			}
			/* this falls through for the last 0 value printed out */

		} else {
			fprintf(stderr, "error: unrecognized opcode [%s] at address %d\n", opcode, address);
			exit(1);
		}

		fprintf(outFilePtr, "%04hx\n", num);
		address++;

	}
}

char * readAndParse(FILE *inFilePtr, char *lineString,
	char **labelPtr, char **opcodePtr, char **arg0Ptr,
	char **arg1Ptr, char **arg2Ptr)
{
	/* read and parse a line
	note that lineString must point to allocated memory,
		so that *labelPtr, *opcodePtr, and *argXPtr
		won't be pointing to readAndParse's memory
	also note that *labelPtr, *opcodePtr, and *argXPtr
		only point to memory in lineString.
	When lineString changes, so will *labelPtr,
		*opcodePtr, and *argXPtr
	returns NULL if at end-of-file */

	char *statusString, *firsttoken;
	statusString = fgets(lineString, MAXLINELENGTH, inFilePtr);
	if (statusString != NULL) {
		firsttoken = strtok(lineString, " \t\n");
		if (firsttoken == NULL || firsttoken[0] == '#') {
			return readAndParse(inFilePtr, lineString, labelPtr, opcodePtr, arg0Ptr, arg1Ptr, arg2Ptr);
		} else if (firsttoken[strlen(firsttoken) - 1] == ':') {
			*labelPtr = firsttoken;
			*opcodePtr = strtok(NULL, " \t\n");
			firsttoken[strlen(firsttoken) - 1] = '\0';
		} else {
			*labelPtr = NULL;
			*opcodePtr = firsttoken;
		}
		*arg0Ptr = strtok(NULL, ", \t\n");
		*arg1Ptr = strtok(NULL, ", \t\n");
		*arg2Ptr = strtok(NULL, ", \t\n");
	}
	return(statusString);
}

int isNumber(char *string) {
	/* return 1 if string is a number */
	int i;
	return( (sscanf(string, "%d", &i)) == 1);
}
