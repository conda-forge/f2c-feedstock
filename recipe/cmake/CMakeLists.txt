# f2c CMAKE build system
# Author: Alexander Reustle (2022)
cmake_minimum_required(VERSION 3.18)

project(
  f2c
  VERSION 20210323183018
  LANGUAGES C
)

## CMake tool support packages. These provide additional funcitons to our Cmake files.
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

########################################################################################
###                       libf2c Shared and Static libraries                         ###
########################################################################################

############## Write common header files ################
file(
  WRITE
  ${CMAKE_SOURCE_DIR}/libf2c/arith.h
  "#define IEEE_8087
#define Arith_Kind_ASL 1
#define Long int
#define Intcast (int)(long)
#define Double_Align
#define X64_bit_pointers
#define NANCHECK
#define QNaN0 0x0
#define QNaN1 0x7ff80000
"
)

file(WRITE ${CMAKE_SOURCE_DIR}/libf2c/MAIN_stub.c "int MAIN__(int argc, char *argv[]) { return 0; }")
file(COPY_FILE ${CMAKE_SOURCE_DIR}/libf2c/signal1.h0 ${CMAKE_SOURCE_DIR}/libf2c/signal1.h)
file(COPY_FILE ${CMAKE_SOURCE_DIR}/libf2c/sysdep1.h0 ${CMAKE_SOURCE_DIR}/libf2c/sysdep1.h)
file(COPY_FILE ${CMAKE_SOURCE_DIR}/libf2c/f2c.h0 ${CMAKE_SOURCE_DIR}/libf2c/f2c.h)
file(READ ${CMAKE_SOURCE_DIR}/libf2c/f2ch.add F2CHADD)
file(APPEND ${CMAKE_SOURCE_DIR}/libf2c/f2c.h "${F2CHADD}")

#### Source object groups as defined in makefile.u

set(MISC f77vers.c i77vers.c main.c MAIN_stub.c s_rnge.c abort_.c exit_.c getarg_.c iargc_.c getenv_.c signal_.c s_stop.c s_paus.c system_.c cabs.c ctype.c derf_.c derfc_.c erf_.c erfc_.c sig_die.c uninit.c)
set(POW pow_ci.c pow_dd.c pow_di.c pow_hh.c pow_ii.c pow_ri.c pow_zi.c pow_zz.c)
set(CX c_abs.c c_cos.c c_div.c c_exp.c c_log.c c_sin.c c_sqrt.c)
set(DCX z_abs.c z_cos.c z_div.c z_exp.c z_log.c z_sin.c z_sqrt.c)
set(REAL r_abs.c r_acos.c r_asin.c r_atan.c r_atn2.c r_cnjg.c r_cos.c r_cosh.c r_dim.c r_exp.c r_imag.c r_int.c r_lg10.c r_log.c r_mod.c r_nint.c r_sign.c r_sin.c r_sinh.c r_sqrt.c r_tan.c r_tanh.c)
set(DBL d_abs.c d_acos.c d_asin.c d_atan.c d_atn2.c d_cnjg.c d_cos.c d_cosh.c d_dim.c d_exp.c d_imag.c d_int.c d_lg10.c d_log.c d_mod.c d_nint.c d_prod.c d_sign.c d_sin.c d_sinh.c d_sqrt.c d_tan.c d_tanh.c)
set(INT i_abs.c i_dim.c i_dnnt.c i_indx.c i_len.c i_mod.c i_nint.c i_sign.c lbitbits.c lbitshft.c)
set(HALF h_abs.c h_dim.c h_dnnt.c h_indx.c h_len.c h_mod.c h_nint.c h_sign.c)
set(CMP l_ge.c l_gt.c l_le.c l_lt.c hl_ge.c hl_gt.c hl_le.c hl_lt.c)
set(EFL ef1asc_.c ef1cmc_.c)
set(CHAR f77_aloc.c s_cat.c s_cmp.c s_copy.c)
set(I77 backspac.c close.c dfe.c dolio.c due.c endfile.c err.c fmt.c fmtlib.c ftell_.c iio.c ilnw.c inquire.c lread.c lwrite.c open.c rdfmt.c rewind.c rsfe.c rsli.c rsne.c sfe.c sue.c typesize.c uio.c util.c wref.c wrtfmt.c wsfe.c wsle.c wsne.c xwsne.c)
set(QINT pow_qq.c qbitbits.c qbitshft.c ftell64_.c)
set(TIME dtime_.c etime_.c)
set(
  OFILES ${MISC} ${POW} ${CX} ${DCX} ${REAL} ${DBL} ${INT} ${HALF} ${CMP} ${EFL}
  ${CHAR} ${I77} ${QINT} ${TIME}
)
list(TRANSFORM OFILES PREPEND "libf2c/")

#### Shared and static library generation

add_library(f2cobjs OBJECT ${OFILES})
target_compile_definitions(f2cobjs PUBLIC Skip_f2c_Undefs INTEGER_STAR_8)

add_library(f2c SHARED $<TARGET_OBJECTS:f2cobjs>)
add_library(f2c_static STATIC $<TARGET_OBJECTS:f2cobjs>)
set_target_properties(f2c PROPERTIES OUTPUT_NAME f2c)
set_target_properties(f2c_static PROPERTIES OUTPUT_NAME f2c POSITION_INDEPENDENT_CODE 1)
target_include_directories(
  f2c PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:>
)
target_include_directories(
  f2c_static PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:>
)
target_compile_definitions(f2c INTERFACE Skip_f2c_Undefs INTEGER_STAR_8)
target_compile_definitions(f2c_static INTERFACE Skip_f2c_Undefs INTEGER_STAR_8)

########################################################################################
###                                  f2c Executable                                  ###
########################################################################################

file(WRITE ${CMAKE_SOURCE_DIR}/src/sysdep.hd "/*OK*/")

set(
  OBJECTSd main.c init.c gram.c lex.c proc.c equiv.c data.c format.c expr.c exec.c
  intr.c io.c misc.c error.c mem.c names.c output.c p1output.c pread.c put.c putpcc.c
  vax.c formatdata.c parse_args.c niceprintf.c cds.c sysdep.c version.c
)
list(TRANSFORM OBJECTSd PREPEND "src/")

add_executable(f2c_bin "${OBJECTSd}")
set_target_properties(f2c_bin PROPERTIES OUTPUT_NAME f2c)

########################################################################################
###                         Specify Installation destinations                        ###
########################################################################################

set(CONFIG_INSTALLDIR lib/cmake/f2c)

install(
  FILES "${CMAKE_SOURCE_DIR}/libf2c/f2c.h"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
install(
  FILES "${CMAKE_SOURCE_DIR}/libf2c/f2c.h"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/f2c"
)

install(
  TARGETS f2c f2c_bin f2c_static
  EXPORT f2cTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(EXPORT f2cTargets NAMESPACE f2c:: DESTINATION ${CONFIG_INSTALLDIR})

configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/f2cConfig.cmake
  INSTALL_DESTINATION ${CONFIG_INSTALLDIR}
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/f2cConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/f2cConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/f2cConfigVersion.cmake
  DESTINATION ${CONFIG_INSTALLDIR}
)

export(
  EXPORT f2cTargets
  FILE ${CMAKE_CURRENT_BINARY_DIR}/f2cTargets.cmake
  NAMESPACE f2c::
)

# Register package in user's package registry
export(PACKAGE f2c)
