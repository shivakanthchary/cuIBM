include Makefile.inc

#test:
#	echo $(PROJ_ROOT)
#	echo $(dir $(lastword $(MAKEFILE_LIST)))

# just so that make is not confused if there exist
# files called cuibm or clean
# a phony target is a name for a recipe to be executed with an explicit request
.PHONY: cuibm src/solvers/libsolvers.a

# this is the command called when 'make' is run in the command line
main: cuibm

# libraries generated by compiling the code
LIBS = lib/libNavierStokesSolvers.a lib/libIO.a

# Libraries for unit tests
TESTLIBS = lib/libTests.a lib/libIO.a

# library generate by compiling the YAML headers
EXT_LIBS = external/lib/libyaml-cpp.a

# final library
FINAL_LIB = lib/libcuIBM.a

# everything after the colon is a prerequisite
# they are all targets that are executed in order before the current target
# if the targets are not explicitly defined, implicit rules are used
# targets are the usually the names of the files generated

# the implicit rule .cu.o converts src/parameterDB.cu to src/parameterDB.o

# link all the object files and libraries to create the executable bin/cuIBM
cuibm: $(LIBS) $(EXT_LIBS) src/helpers.o src/parameterDB.o src/bodies.o src/cuIBM.o
	nvcc $^ -o bin/cuIBM

unitTests/convectionTerm: $(TESTLIBS) $(EXT_LIBS) src/helpers.o src/parameterDB.o src/unitTests/convectionTerm.o
	nvcc $^ -o bin/unitTests/convectionTerm

#src/preconditioner.o

#lib/libcuIBM.a: $(LIBS) $(EXT_LIBS)
#	cd lib; libtool -static -o libcuIBM.a $^

#  force_look is a dependency
#  it is always true. So this command is always executed
#  MFLAGS is used to transfer command line options to the sub-makes
lib/libNavierStokesSolvers.a: force_look
	cd src/solvers; $(MAKE) $(MFLAGS)
  
lib/libIO.a: force_look
	cd src/io/; $(MAKE) $(MFLAGS)

external/lib/libyaml-cpp.a:
	cd external; $(MAKE) $(MFLAGS) all

lib/libTests.a: force_look
	cd src/solvers; $(MAKE) $(MFLAGS) tests

#  deletes all the object files
#  it seems MFLAGS hasn't been defined anywhere. The defaults are probably used.
#  @ at the beginning of a line suppresses output. This works only in Makefiles.
#  1. delete all the .a and .o files
#  2. cd to the concerned folders
#  3. run 'make clean' as defined in the Makefiles in those folders
.PHONY: clean cleanall

clean:
	@rm -f lib/*.a bin/cuIBM src/*.o src/unitTests/*.o
	@rm -f body.txt tagx.txt tagy.txt
	cd src/solvers; $(MAKE) $(MFLAGS) clean
	cd src/io; $(MAKE) $(MFLAGS) clean

cleanall:
	@rm -f lib/*.a bin/cuIBM src/*.o
	cd src/solvers; $(MAKE) $(MFLAGS) clean
	cd src/io; $(MAKE) $(MFLAGS) clean
	cd external; $(MAKE) $(MFLAGS) clean

force_look:
	true

testConvection:
	bin/unitTests/convectionTerm -caseFolder cases/unitTests/convectionTerm/6
	bin/unitTests/convectionTerm -caseFolder cases/unitTests/convectionTerm/12
	bin/unitTests/convectionTerm -caseFolder cases/unitTests/convectionTerm/24

lidDrivenCavityRe100:
	bin/cuIBM -caseFolder cases/lidDrivenCavity/Re100

lidDrivenCavityRe1000:
	bin/cuIBM -caseFolder cases/lidDrivenCavity/Re1000

cylinder:
	bin/cuIBM -caseFolder cases/cylinder/test

cylinderRe40:
	bin/cuIBM -caseFolder cases/cylinder/Re40

cylinderRe550:
	bin/cuIBM -caseFolder cases/cylinder/Re550

cylinderRe3000:
	bin/cuIBM -caseFolder cases/cylinder/Re3000

cylinderRe75:
	bin/cuIBM -caseFolder cases/cylinder/Re75

cylinderRe100:
	bin/cuIBM -caseFolder cases/cylinder/Re100

cylinderRe150:
	bin/cuIBM -caseFolder cases/cylinder/Re150

cylinderFadlun:
	bin/cuIBM -caseFolder cases/cylinder/Re40 -ibmScheme FadlunEtAl

snakeRe1000AOA30:
	time bin/cuIBM -caseFolder cases/flyingSnake/Re1000_AoA30

snakeRe1000AOA35:
	time bin/cuIBM -caseFolder cases/flyingSnake/Re1000_AoA35

snakeRe2000AOA30:
	time bin/cuIBM -caseFolder cases/flyingSnake/Re2000_AoA30

snakeRe2000AOA35:
	time bin/cuIBM -caseFolder cases/flyingSnake/Re2000_AoA35

flappingRe75:
	time bin/cuIBM -caseFolder cases/flappingRe75

oscillatingCylinders:
	time bin/cuIBM -caseFolder cases/oscillatingCylinders
