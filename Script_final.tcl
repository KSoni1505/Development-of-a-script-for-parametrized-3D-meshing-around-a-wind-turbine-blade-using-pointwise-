###################################################################################################
#
# ---------------------------------------------------------------------------------
#  Script: Development of a script for parametrized 3D-meshing
#              around a wind turbine blade using pointwise
# ---------------------------------------------------------------------------------
# 
#  Written by Karan Jayeshbhai Soni
#
# Supervising and guding by : Prof. Dr. A. P. Schaffarczyk and Brandon Lobo
#
# Date : 31.August.2023
#
###################################################################################################

# Load Pointwise Glyph package and Tk
package require Tk
package require PWI_Glyph 6.22.1

# Set generic value using 'set'command
set NUMBER_OF_CONNECTORS "48"; # Change the number of connectors 
set SPACING_CONSTRAINT_VALUE "0.05"; # change the spacing value
set CYLINDER_RADIUS "5000";
# look for the values corresponding to z1 and z2 to change the cylinder's length. 
set z1 "-3369.3018";  set z2 "-100000"; 
set x1 "0"; # To move the cylinder in the x-direction, change the value of x1 
set y1 "0"; # change the value of y1 to move the cylinder in the y-direction.
set z3 "-1000"; # change the value of 120 degree of block 
set upwind_distance "500000";
set downwind_distance "800000";

################################################################################################

# Function to run your original process with updated parameters
proc runOriginalProcess {} {
    # Access global variables within this procedure
    global NUMBER_OF_CONNECTORS SPACING_CONSTRAINT_VALUE CYLINDER_RADIUS y1 z1 z2 x1 z3 upwind_distance downwind_distance
    # Use the parameter values in your original process logic
    puts "Number of Connectors: $NUMBER_OF_CONNECTORS"
    puts "Spacing Constraint Value: $SPACING_CONSTRAINT_VALUE"
    puts "Cylinder radius: $CYLINDER_RADIUS"
    puts "y1: $y1"
    puts "z1: $z1"
    puts "z2: $z2"
    puts "x1: $x1"
    puts "z3: $z3"
    puts "upwind distance: $upwind_distance"
    puts "downwind distance: $downwind_distance"

# ----------------------------------------------------------------------------------------------
# IMPORT FILE 
# ----------------------------------------------------------------------------------------------

set IMPORT_FILE [pw::Application begin DatabaseImport]
  $IMPORT_FILE initialize -strict -type Automatic {C:/Users/soni/Desktop/Airfoil Data/CIG10MW-blade.STEP}
  $IMPORT_FILE setAttribute FileUnits Millimeters
  $IMPORT_FILE read
  $IMPORT_FILE convert
$IMPORT_FILE end

#################################################################################################
# FIRST DEFINED WIND TURBINE BLADE IN POINTWISE SOFTWARE
#################################################################################################

# CONVERTORS ON DATA BASE ENTITIES
set NONE_9 [pw::DatabaseEntity getByName NONE-9]
set NONE_8 [pw::DatabaseEntity getByName NONE-8]
set NONE_3 [pw::DatabaseEntity getByName NONE-3]
set CONNECTORS_ON_DATA_BASE_ENTITIES [pw::Connector createOnDatabase -parametricConnectors Aligned -merge 0 -reject _TMP(unused) [list $NONE_9 $NONE_8 $NONE_3]]
pw::Entity delete [list $NONE_9 $NONE_8 $NONE_3]

# SPLIT_PIECES_ON_TIP_SIDE
set PRESSURE_INLET_TIP_SIDE [pw::GridEntity getByName con-3]
set SPLIT [list]
lappend SPLIT 0.50448932352831566
set SPLIT_ROOT_SIDE_AIRFOIL [$PRESSURE_INLET_TIP_SIDE split $SPLIT]

# ROOT SIDE AIR FOIL SPLIT INTO TWO PARTS
set ROOTSIDE_AIRFOIL [pw::GridEntity getByName con-1]
set SPLIT_1 [list]
lappend SPLIT_1 0.74661304376480153
set SPLIT_TIP_SIDE_AIR_FOIL [$ROOTSIDE_AIRFOIL split $SPLIT_1]

# GIVEN THE NAMES OF ROOT SIDE SPLIT AIRFOIL
set _TMP(mode_1) [pw::Application begin Create]
  set _TMP(PW_1) [pw::SegmentSpline create]
  set OLD_ROOT_SIDE_PRESSURE_INLET_AIRFOIL [pw::GridEntity getByName con-1-split-1]
  set OLD_ROOT_SIDE_PRESSURE_OUTLET_AIRFOIL [pw::GridEntity getByName con-1-split-2]
$_TMP(mode_1) abort

# GIVEN_THE_CONNECTORS_NAMES
set DIFINE_NAMES [pw::Application begin Create]
  set CONNECTORS_NAMES [pw::SegmentSpline create]
  set POINT_OF_TIP_SIDE_LEADING_EDGE [pw::GridEntity getByName con-3-split-1]
  set PRESSURE_OUTLET_TIP_SIDE [pw::GridEntity getByName con-3-split-2]
  set TRAILING_EDGE_TIP_SIDE [pw::GridEntity getByName con-6]
  set TRAILING_EDGE_PRESSURE_INLET_SIDE [pw::GridEntity getByName con-2]
  set TRAILING_EDGE_PRESSURE_OUTLET_SIDE [pw::GridEntity getByName con-4]

# CREATE A LEADING_EDGE
  $CONNECTORS_NAMES addPoint [$POINT_OF_TIP_SIDE_LEADING_EDGE getPosition -arc 1]
  $CONNECTORS_NAMES addPoint [$OLD_ROOT_SIDE_PRESSURE_INLET_AIRFOIL getPosition -arc 1]
  set CREATE_A_LEADING_EDGE [pw::Connector create]
  $CREATE_A_LEADING_EDGE addSegment $CONNECTORS_NAMES
  $CREATE_A_LEADING_EDGE calculateDimension
$DIFINE_NAMES end

# DELETE ROOT SIDE AITFOIL
pw::Entity delete [list $OLD_ROOT_SIDE_PRESSURE_INLET_AIRFOIL $OLD_ROOT_SIDE_PRESSURE_OUTLET_AIRFOIL]

# DELETE ROOT SIDE OF TRAILING EDGE
set DELETE_ROOT_SIDE_OF_TRAILING_EDGE [pw::GridEntity getByName con-5]
pw::Entity delete [list $DELETE_ROOT_SIDE_OF_TRAILING_EDGE]

# SPLIT TRAILING EDGE PRESSURE INLET SIDE NEAR TO ROOT SIDE
set TRAILING_EDGE_PRESSURE_INLET_SPLIT [pw::DatabaseEntity getByName NONE-edge-1]
set SPLIT_2 [list]
lappend SPLIT_2 [$TRAILING_EDGE_PRESSURE_INLET_SIDE getParameter -closest [pw::Application getXYZ [$TRAILING_EDGE_PRESSURE_INLET_SIDE closestPoint {2157.6119 625.23612 -3369.3018}]]]
set SPLIT_INTO_LIST [$TRAILING_EDGE_PRESSURE_INLET_SIDE split $SPLIT_2]

# DELETE_TRAILING_EDGE_PRESSURE_INLET_SIDE_ONE_SPLIT
set DELETE_SPLIT_TRAILING_EDGE_PSI [pw::GridEntity getByName con-2-split-1]
pw::Entity delete [list $DELETE_SPLIT_TRAILING_EDGE_PSI]

# CREATE ROOT SIDE TRAILING EDGE
set ROOT_SIDE_TRAILING_EDGE_LINE [pw::Application begin Create]
  set TWO_POINTS_CONSIDER_FOR_CREATING_LINE [pw::SegmentSpline create]
  set TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE [pw::GridEntity getByName con-2-split-2]
  set _DB(7) [pw::DatabaseEntity getByName curve-11]
  set _DB(8) [pw::DatabaseEntity getByName NONE-2]
  $TWO_POINTS_CONSIDER_FOR_CREATING_LINE addPoint [$TRAILING_EDGE_PRESSURE_OUTLET_SIDE getPosition -arc 1]
  $TWO_POINTS_CONSIDER_FOR_CREATING_LINE addPoint [$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE getPosition -arc 0]
  set CREATE_ROOT_SIDE_TRAILING_EDGE [pw::Connector create]
  $CREATE_ROOT_SIDE_TRAILING_EDGE addSegment $TWO_POINTS_CONSIDER_FOR_CREATING_LINE
  $CREATE_ROOT_SIDE_TRAILING_EDGE calculateDimension
$ROOT_SIDE_TRAILING_EDGE_LINE end

# SPLIT_TRAILING_EDGE_NEAR_TO_ROOT_SIDE
set STENTRS_FOR_CREATE_RSAF [pw::Application begin Create]
 set _TMP(PW_1) [pw::SegmentSpline create]
$STENTRS_FOR_CREATE_RSAF abort
set _DB(9) [pw::DatabaseEntity getByName NONE-edge]
set SPLIT_3 [list]
lappend SPLIT_3 [$CREATE_A_LEADING_EDGE getParameter -closest [pw::Application getXYZ [$CREATE_A_LEADING_EDGE closestPoint {-2160.95 -628.825 -3369.3018}]]]
set SPLIT_TRAILING_EDGE_NEAR_TO_ROOT_SIDE [$CREATE_A_LEADING_EDGE split $SPLIT_3]

# DELETE TRAILING EDGE NEAR TO ROOT SIDE
set DELETE_TENTRS [pw::GridEntity getByName con-7-split-2]
pw::Entity delete [list $DELETE_TENTRS]

# CREATE A CENTER POINT OF ROOT SIDE
set C_A_C_P_O_R_S [pw::Application begin Create]
  set ROOT_CENTER_POINT [pw::SegmentSpline create]
  $ROOT_CENTER_POINT addPoint {0 0 -3369.3018}
  set ROOT_SIDE_OF_CENTER_POINT [pw::Connector create]
  $ROOT_SIDE_OF_CENTER_POINT addSegment $ROOT_CENTER_POINT
$C_A_C_P_O_R_S end

# CREATE A ROOT SIDE PRESSURE INLET AIRFOIL
set SSC [pw::Application begin Create]
  set SSC_1 [pw::SegmentSpline create]
$SSC abort
set GSC [pw::Application begin Create]
  set GSC_1 [pw::GridShape create]
$GSC abort
set CARSPIA [pw::Application begin Create]
  set CREATE_A_CIRCLE_WITH_2POINTS_CENTER [pw::SegmentCircle create]
  set _CN(17) [pw::GridEntity getByName con-7-split-1]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER addPoint [$_CN(17) getPosition -arc 1]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER addPoint [$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE getPosition -arc 0]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER setCenterPoint {-1.98338621056762 -0.575952297105568 -3369.30179920079} {0 0 1}
  set CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL [pw::Connector create]
  $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL addSegment $CREATE_A_CIRCLE_WITH_2POINTS_CENTER
$CARSPIA end


# CREATE A ROOT SIDE PRESSURE OUTSIDE AIRFOIL
set SCC [pw::Application begin Create]
  set SCC_1 [pw::SegmentCircle create]
$SCC abort
set CARSPOA [pw::Application begin Create]
  set CREATE_A_CIRCLE_WITH_2POINTS_CENTER_OTHERSIDE [pw::SegmentCircle create]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER_OTHERSIDE addPoint [$_CN(17) getPosition -arc 1]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER_OTHERSIDE addPoint [$TRAILING_EDGE_PRESSURE_OUTLET_SIDE getPosition -arc 1]
  $CREATE_A_CIRCLE_WITH_2POINTS_CENTER_OTHERSIDE setCenterPoint {-1.98442588961047 -0.579218299576131 -3369.30179918558} {0 0 1}
  set CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL [pw::Connector create]
  $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL addSegment $CREATE_A_CIRCLE_WITH_2POINTS_CENTER_OTHERSIDE
$CARSPOA end

###########################################################################################################
# END POINTWISE SOFTWARE PROCESS
###########################################################################################################

#########################################################################################################
# STARTING MAIN SCRIPT AT HERE
# DEFINE A NUMBER OF CONNECTOR, SET NAME AND SPACING CONSTRAINT VALUE 
#########################################################################################################

# TIPSIDE AIRFOIL 
# P_O_T_S_L_E = PRESSURE OUTLET TIPSIDE LEADING EDGE
# P_I_T_S = PRESSURE INLET TIP SIDE LEADING EDGE 
# T_E_T_S = TRAILING EDGE TIPSIDE

set P_O_T_S_L_E [pw::GridEntity getByName con-3-split-1]
$P_O_T_S_L_E setName TIPSIDE_PRESSURE_OUTLET;
$P_O_T_S_L_E setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set S_C_P_O_T_S_L_E [pw::Application begin Modify [list $P_O_T_S_L_E]]
  set S_C_V_P_O_T_S_L_E [$P_O_T_S_L_E getDistribution 1]
  $S_C_V_P_O_T_S_L_E setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]; 
  $S_C_V_P_O_T_S_L_E setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_P_O_T_S_L_E end

set P_I_T_S [pw::GridEntity getByName con-3-split-2]
$P_I_T_S setName TIPSIDE_PRESSURE_INLET;
$P_I_T_S setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set S_C_P_I_T_S [pw::Application begin Modify [list $P_I_T_S]]
  set S_C_V_P_I_T_S [$P_I_T_S getDistribution 1]
  $S_C_V_P_I_T_S setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_C_V_P_I_T_S setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_P_I_T_S end

set T_E_T_S [pw::GridEntity getByName con-6]
$T_E_T_S setName TIPSIDE_TRAILING_EDGE;
$T_E_T_S setDimension [expr "$NUMBER_OF_CONNECTORS"]
set S_C_T_E_T_S [pw::Application begin Modify [list $T_E_T_S]]
  set S_C_V_T_E_T_S [$T_E_T_S getDistribution 1]
  $S_C_V_T_E_T_S setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_C_V_T_E_T_S setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_T_E_T_S end

# ROOTSIDE AIRFOIL 

$CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set S_C_P_I_RS [pw::Application begin Modify [list $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL]]
 set S_C_V_P_I_RS [$CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL getDistribution 1]
 $S_C_V_P_I_RS setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
 $S_C_V_P_I_RS setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_P_I_RS end

$CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set S_C_P_O_RS [pw::Application begin Modify [list $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL]]
 set S_C_V_P_O_RS [$CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL getDistribution 1]
 $S_C_V_P_O_RS setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
 $S_C_V_P_O_RS setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_P_O_RS end

# SPLIT TRAILING EDGE (PRESSURE OUTLET SIDE) 

# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (1)
set SPLIT_4_1 [list]
lappend SPLIT_4_1 [$TRAILING_EDGE_PRESSURE_OUTLET_SIDE getParameter -Z -[expr "-$z2 - 95378"]]
set TEPOS_1 [$TRAILING_EDGE_PRESSURE_OUTLET_SIDE split $SPLIT_4_1]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (2)
set TE_P_OS_2 [pw::GridEntity getByName con-4-split-1]
set SPLIT_4_2 [list]
lappend SPLIT_4_2 [$TE_P_OS_2 getParameter -Z -[expr "-$z2 - 94157"]]
set TEPOS_2 [$TE_P_OS_2 split $SPLIT_4_2]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (3)
set TE_P_OS_3 [pw::GridEntity getByName con-4-split-1-split-1]
set SPLIT_4_3 [list]
lappend SPLIT_4_3 [$TE_P_OS_3 getParameter -Z -[expr "-$z2 - 90618"]]
set TEPOS_3 [$TE_P_OS_3 split $SPLIT_4_3]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (4)
set REMANING_PARTS [pw::GridEntity getByName con-4-split-1-split-1-split-1]
set TE_POS_3 [pw::GridEntity getByName con-4-split-1-split-1-split-2]
set SPLIT_4_4 [list]
lappend SPLIT_4_4 [$REMANING_PARTS getParameter -Z -[expr "-$z2 - 83928"]]
set _TMP(PW_1) [$REMANING_PARTS split $SPLIT_4_4]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (5)
set TE_P_OS_5 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1]
set SPLIT_4_5 [list]
lappend SPLIT_4_5 [$TE_P_OS_5 getParameter -Z -[expr "-$z2 - 79546"]]
set TEPOS_5 [$TE_P_OS_5 split $SPLIT_4_5]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (6)
set TE_P_OS_6 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_6 [list]
lappend SPLIT_4_6 [$TE_P_OS_6 getParameter -Z -[expr "-$z2 - 75402"]]
set TEPOS_6 [$TE_P_OS_6 split $SPLIT_4_6]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (7)
set TE_P_OS_7 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_7 [list]
lappend SPLIT_4_7 [$TE_P_OS_7 getParameter -Z -[expr "-$z2 - 70427"]]
set TEPOS_7 [$TE_P_OS_7 split $SPLIT_4_7]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (8)
set TE_P_OS_8 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_8 [list]
lappend SPLIT_4_8 [$TE_P_OS_8 getParameter -Z -[expr "-$z2 - 64712"]]
set TEPOS_8 [$TE_P_OS_8 split $SPLIT_4_8]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE ------------------ (9)
set TE_P_OS_9 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_9 [list]
lappend SPLIT_4_9 [$TE_P_OS_9 getParameter -Z -[expr "-$z2 - 38209"]]
set TEPOS_9 [$TE_P_OS_9 split $SPLIT_4_9]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE _ (10)
set TE_P_OS_10 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_10 [list]
lappend SPLIT_4_10 [$TE_P_OS_10 getParameter -Z -[expr "-$z2 - 11427"]]
set TEPOS_10 [$TE_P_OS_10 split $SPLIT_4_10]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE _ (11)
set TE_P_OS_11 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_11 [list]
lappend SPLIT_4_11 [$TE_P_OS_11 getParameter -Z -[expr "-$z2 - 5044"]]
set TEPOS_11 [$TE_P_OS_11 split $SPLIT_4_11]
# SPLIT OF TRAILING EDGE PRESSURE OUTLET SIDE _ (12)
set TE_P_OS_12 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_4_12 [list]
lappend SPLIT_4_12 [$TE_P_OS_12 getParameter -Z -[expr "-$z2 - 2222"]]
set TEPOS_12 [$TE_P_OS_12 split $SPLIT_4_12]

# NUMBER OF CONNECTOR AND SPACING VALUE ON TRAINNING PRESSURE OUTLETSIDE

set N_C_T_P_O_S_1 [pw::GridEntity getByName con-4-split-2]
$N_C_T_P_O_S_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
set S_C_N_C_T_P_O_S_1 [pw::Application begin Modify [list $N_C_T_P_O_S_1]]
  set S_C_V_N_C_T_P_O_S_1 [$N_C_T_P_O_S_1 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_1 setBeginSpacing 222.75
  $S_C_V_N_C_T_P_O_S_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_N_C_T_P_O_S_1 end

set N_C_T_P_O_S_2 [pw::GridEntity getByName con-4-split-1-split-2]
$N_C_T_P_O_S_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
set S_C_N_C_T_P_O_S_2 [pw::Application begin Modify [list $N_C_T_P_O_S_2]]
  set S_C_V_N_C_T_P_O_S_2 [$N_C_T_P_O_S_2 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_2 setBeginSpacing 426.45
  $S_C_V_N_C_T_P_O_S_2 setEndSpacing 222.53
$S_C_N_C_T_P_O_S_2 end

set N_C_T_P_O_S_3 [pw::GridEntity getByName con-4-split-1-split-1-split-2]
$N_C_T_P_O_S_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_N_C_T_P_O_S_3 [pw::Application begin Modify [list $N_C_T_P_O_S_3]]
  set S_C_V_N_C_T_P_O_S_3 [$N_C_T_P_O_S_3 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_3 setBeginSpacing 644
  $S_C_V_N_C_T_P_O_S_3 setEndSpacing 428.14
$S_C_N_C_T_P_O_S_3 end

set N_C_T_P_O_S_4 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
set S_C_N_C_T_P_O_S_4 [pw::Application begin Modify [list $N_C_T_P_O_S_4]]
  set S_C_V_N_C_T_P_O_S_4 [$N_C_T_P_O_S_4 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_4 setBeginSpacing 628.90
  $S_C_V_N_C_T_P_O_S_4 setEndSpacing 607.89
$S_C_N_C_T_P_O_S_4 end

set N_C_T_P_O_S_5 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_N_C_T_P_O_S_5 [pw::Application begin Modify [list $N_C_T_P_O_S_5]]
  set S_C_V_N_C_T_P_O_S_5 [$N_C_T_P_O_S_5 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_5 setBeginSpacing 632.36
  $S_C_V_N_C_T_P_O_S_5 setEndSpacing 622.44
$S_C_N_C_T_P_O_S_5 end

set N_C_T_P_O_S_6 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_N_C_T_P_O_S_6 [pw::Application begin Modify [list $N_C_T_P_O_S_6]]
  set S_C_V_N_C_T_P_O_S_6 [$N_C_T_P_O_S_6 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_6 setBeginSpacing 796.37
  $S_C_V_N_C_T_P_O_S_6 setEndSpacing 632.31
$S_C_N_C_T_P_O_S_6 end

set N_C_T_P_O_S_7 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_N_C_T_P_O_S_7 [pw::Application begin Modify [list $N_C_T_P_O_S_7]]
  set S_C_V_N_C_T_P_O_S_7 [$N_C_T_P_O_S_7 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_7 setBeginSpacing 875.13
  $S_C_V_N_C_T_P_O_S_7 setEndSpacing 798.60
$S_C_N_C_T_P_O_S_7 end

set N_C_T_P_O_S_8 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_N_C_T_P_O_S_8 [pw::Application begin Modify [list $N_C_T_P_O_S_8]]
  set S_C_V_N_C_T_P_O_S_8 [$N_C_T_P_O_S_8 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_8 setBeginSpacing 1079.97
  $S_C_V_N_C_T_P_O_S_8 setEndSpacing 880.60
$S_C_N_C_T_P_O_S_8 end

set N_C_T_P_O_S_9 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_N_C_T_P_O_S_9 [pw::Application begin Modify [list $N_C_T_P_O_S_9]]
  set S_C_V_N_C_T_P_O_S_9 [$N_C_T_P_O_S_9 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_9 setBeginSpacing 1053.08
  $S_C_V_N_C_T_P_O_S_9 setEndSpacing 1080.58
$S_C_N_C_T_P_O_S_9 end

set N_C_T_P_O_S_10 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_N_C_T_P_O_S_10 [pw::Application begin Modify [list $N_C_T_P_O_S_10]]
  set S_C_V_N_C_T_P_O_S_10 [$N_C_T_P_O_S_10 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_10 setBeginSpacing 1107
  $S_C_V_N_C_T_P_O_S_10 setEndSpacing 1053
$S_C_N_C_T_P_O_S_10 end

set N_C_T_P_O_S_11 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_N_C_T_P_O_S_11 [pw::Application begin Modify [list $N_C_T_P_O_S_11]]
  set S_C_V_N_C_T_P_O_S_11 [$N_C_T_P_O_S_11 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_11 setBeginSpacing 796.89
  $S_C_V_N_C_T_P_O_S_11 setEndSpacing 1107.23
$S_C_N_C_T_P_O_S_11 end

set N_C_T_P_O_S_12 [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_T_P_O_S_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
set S_C_N_C_T_P_O_S_12 [pw::Application begin Modify [list $N_C_T_P_O_S_12]]
  set S_C_V_N_C_T_P_O_S_12 [$N_C_T_P_O_S_12 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_12 setBeginSpacing 427.02
  $S_C_V_N_C_T_P_O_S_12 setEndSpacing 796.81
$S_C_N_C_T_P_O_S_12 end

$TE_P_OS_12 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
set S_C_N_C_T_P_O_S_13 [pw::Application begin Modify [list $TE_P_OS_12]]
  set S_C_V_N_C_T_P_O_S_13 [$TE_P_OS_12 getDistribution 1]
  $S_C_V_N_C_T_P_O_S_13 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_C_V_N_C_T_P_O_S_13 setEndSpacing 427.72
$S_C_N_C_T_P_O_S_13 end

# SPLIT TRAILING EDGE (PRESSURE INLET SIDE)
# NUMBER OF CONNECTIRS AND SPACING CONSTRAINT VALUE

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ---------------------------- (1)
set SPLIT_5_1 [list]
lappend SPLIT_5_1 [$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE getParameter -Z -[expr "-$z2 - 95378"]]
set TEPIS_1 [$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE split $SPLIT_5_1]
$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE setDimension [expr "$NUMBER_OF_CONNECTORS"]
set SC_TEPIS_1 [pw::Application begin Modify [list $TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE]]
  set SCV_TEPIS_1 [$TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE getDistribution 1]
  $SCV_TEPIS_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $SCV_TEPIS_1 setEndSpacing 222.75
$SC_TEPIS_1 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ---------------------------- (2)
set TE_P_IS_2 [pw::GridEntity getByName con-2-split-2-split-2]
set SPLIT_5_2 [list]
lappend SPLIT_5_2 [$TE_P_IS_2 getParameter -Z -[expr "-$z2 - 94157"]]
set TEPIS_2 [$TE_P_IS_2 split $SPLIT_5_2]
$TE_P_IS_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
set SC_TEPIS_2 [pw::Application begin Modify [list $TE_P_IS_2]]
  set SCV_TEPIS_2 [$TE_P_IS_2 getDistribution 1]
  $SCV_TEPIS_2 setBeginSpacing 222.53
  $SCV_TEPIS_2 setEndSpacing 426.45
$SC_TEPIS_2 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ----------------------------- (3)
set TE_P_IS_3 [pw::GridEntity getByName con-2-split-2-split-2-split-2]
set SPLIT_5_3 [list]
lappend SPLIT_5_3 [$TE_P_IS_3 getParameter -Z -[expr "-$z2 - 90618"]]
set TEPIS_3 [$TE_P_IS_3 split $SPLIT_5_3]
$TE_P_IS_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set SC_TEPIS_3 [pw::Application begin Modify [list $TE_P_IS_3]]
  set SCV_TEPIS_3 [$TE_P_IS_3 getDistribution 1]
  $SCV_TEPIS_3 setBeginSpacing 428.14
  $SCV_TEPIS_3 setEndSpacing 644
$SC_TEPIS_3 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ----------------------------- (4)
set TE_P_IS_4 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2]
set SPLIT_5_4 [list]
lappend SPLIT_5_4 [$TE_P_IS_4 getParameter -Z -[expr "-$z2 - 83928"]]
set TEPIS_4 [$TE_P_IS_4 split $SPLIT_5_4]
$TE_P_IS_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
set SC_TEPIS_4 [pw::Application begin Modify [list $TE_P_IS_4]]
  set SCV_TEPIS_4 [$TE_P_IS_4 getDistribution 1]
  $SCV_TEPIS_4 setBeginSpacing 607.89
  $SCV_TEPIS_4 setEndSpacing 628.90
$SC_TEPIS_4 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE -------------------------------(5)
set TE_P_IS_5 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_5 [list]
lappend SPLIT_5_5 [$TE_P_IS_5 getParameter -Z -[expr "-$z2 - 79546"]]
set TEPIS_5 [$TE_P_IS_5 split $SPLIT_5_5]
$TE_P_IS_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set SC_TEPIS_5 [pw::Application begin Modify [list $TE_P_IS_5]]
  set SCV_TEPIS_5 [$TE_P_IS_5 getDistribution 1]
  $SCV_TEPIS_5 setBeginSpacing 622.44
  $SCV_TEPIS_5 setEndSpacing 632.36
$SC_TEPIS_5 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE --------------------------------(6)
set TE_P_IS_6 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_6 [list]
lappend SPLIT_5_6 [$TE_P_IS_6 getParameter -Z -[expr "-$z2 - 75402"]]
set TEPIS_6 [$TE_P_IS_6 split $SPLIT_5_6]
$TE_P_IS_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set SC_TEPIS_6 [pw::Application begin Modify [list $TE_P_IS_6]]
  set SCV_TEPIS_6 [$TE_P_IS_6 getDistribution 1]
  $SCV_TEPIS_6 setBeginSpacing 632.31
  $SCV_TEPIS_6 setEndSpacing 796.37
$SC_TEPIS_6 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE --------------------------------- (7)
set TE_P_IS_7 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_7 [list]
lappend SPLIT_5_7 [$TE_P_IS_7 getParameter -Z -[expr "-$z2 - 70427"]]
set TEPIS_7 [$TE_P_IS_7 split $SPLIT_5_7]
$TE_P_IS_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set SC_TEPIS_7 [pw::Application begin Modify [list $TE_P_IS_7]]
  set SCV_TEPIS_7 [$TE_P_IS_7 getDistribution 1]
  $SCV_TEPIS_7 setBeginSpacing 798.60
  $SCV_TEPIS_7 setEndSpacing 875.13
$SC_TEPIS_7 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ---------------------------------- (8)
set TE_P_IS_8 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_8 [list]
lappend SPLIT_5_8 [$TE_P_IS_8 getParameter -Z -[expr "-$z2 - 64712"]]
set TEPIS_8 [$TE_P_IS_8 split $SPLIT_5_8]
$TE_P_IS_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set SC_TEPIS_8 [pw::Application begin Modify [list $TE_P_IS_8]]
  set SCV_TEPIS_8 [$TE_P_IS_8 getDistribution 1]
  $SCV_TEPIS_8 setBeginSpacing 880.60
  $SCV_TEPIS_8 setEndSpacing 1079.97
$SC_TEPIS_8 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ------------------------------------(9)
set TE_P_IS_9 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_9 [list]
lappend SPLIT_5_9 [$TE_P_IS_9 getParameter -Z -[expr "-$z2 - 38209"]]
set TEPIS_9 [$TE_P_IS_9 split $SPLIT_5_9]
$TE_P_IS_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set SC_TEPIS_9 [pw::Application begin Modify [list $TE_P_IS_9]]
  set SCV_TEPIS_9 [$TE_P_IS_9 getDistribution 1]
  $SCV_TEPIS_9 setBeginSpacing 1080.58
  $SCV_TEPIS_9 setEndSpacing 1053.08
$SC_TEPIS_9 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ------------------------------------ (10)
set TE_P_IS_10 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_10 [list]
lappend SPLIT_5_10 [$TE_P_IS_10 getParameter -Z -[expr "-$z2 - 11427"]]
set TEPIS_10 [$TE_P_IS_10 split $SPLIT_5_10]
$TE_P_IS_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set SC_TEPIS_10 [pw::Application begin Modify [list $TE_P_IS_10]]
  set SCV_TEPIS_10 [$TE_P_IS_10 getDistribution 1]
  $SCV_TEPIS_10 setBeginSpacing 1053
  $SCV_TEPIS_10 setEndSpacing 1107
$SC_TEPIS_10 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE -------------------------------------(11)
set TE_P_IS_11 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_11 [list]
lappend SPLIT_5_11 [$TE_P_IS_11 getParameter -Z -[expr "-$z2 - 5044"]]
set TEPIS_11 [$TE_P_IS_11 split $SPLIT_5_11]
$TE_P_IS_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set SC_TEPIS_11 [pw::Application begin Modify [list $TE_P_IS_11]]
  set SCV_TEPIS_11 [$TE_P_IS_11 getDistribution 1]
  $SCV_TEPIS_11 setBeginSpacing 1107.23
  $SCV_TEPIS_11 setEndSpacing 796.89
$SC_TEPIS_11 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ------------------------------------(12)
set TE_P_IS_12 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
set SPLIT_5_12 [list]
lappend SPLIT_5_12 [$TE_P_IS_12 getParameter -Z -[expr "-$z2 - 2222"]]
set TEPIS_12 [$TE_P_IS_12 split $SPLIT_5_12]
$TE_P_IS_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
set SC_TEPIS_12 [pw::Application begin Modify [list $TE_P_IS_12]]
  set SCV_TEPIS_12 [$TE_P_IS_12 getDistribution 1]
  $SCV_TEPIS_12 setBeginSpacing 796.81
  $SCV_TEPIS_12 setEndSpacing 427.02
$SC_TEPIS_12 end

# SPLIT OF TRAILING EDGE PRESSURE INLET SIDE ------------------------------------(13)
set TE_P_IS_13 [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2]
$TE_P_IS_13 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
$TE_P_IS_13 setName TE_1
set SC_TEPIS_13 [pw::Application begin Modify [list $TE_P_IS_13]]
  set SCV_TEPIS_13 [$TE_P_IS_13 getDistribution 1]
  $SCV_TEPIS_13 setBeginSpacing 427.72
  $SCV_TEPIS_13 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$SC_TEPIS_13 end

# SPLIT OF LEADING EDGE

# SPLIT OF LEADING EDGE --------------------------------------------------- (1)
set SOLE_1 [pw::Application begin Create]
set LE_1 [pw::SegmentSpline create]
$SOLE_1 abort
set SPLIT_6_1 [list]
lappend SPLIT_6_1 [$_CN(17) getParameter -Z -[expr "-$z2 - 95378"]]
set LE_1 [$_CN(17) split $SPLIT_6_1]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (2)
set SOLE_2 [pw::GridEntity getByName con-7-split-1-split-1]
set SPLIT_6_2 [list]
lappend SPLIT_6_2 [$SOLE_2 getParameter -Z -[expr "-$z2 - 94157"]]
set LE_2 [$SOLE_2 split $SPLIT_6_2]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (3)
set SOLE_3 [pw::GridEntity getByName con-7-split-1-split-1-split-1]
set SPLIT_6_3 [list]
lappend SPLIT_6_3 [$SOLE_3 getParameter -Z -[expr "-$z2 - 90618"]]
set LE_3 [$SOLE_3 split $SPLIT_6_3]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (4)
set SOLE_4 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1]
set SPLIT_6_4 [list]
lappend SPLIT_6_4 [$SOLE_4 getParameter -Z -[expr "-$z2 - 83928"]]
set LE_4 [$SOLE_4 split $SPLIT_6_4]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (5)
set SOLE_5 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_5 [list]
lappend SPLIT_6_5 [$SOLE_5 getParameter -Z -[expr "-$z2 - 79546"]]
set LE_5 [$SOLE_5 split $SPLIT_6_5]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (6)
set SOLE_6 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_6 [list]
lappend SPLIT_6_6 [$SOLE_6 getParameter -Z -[expr "-$z2 - 75402"]]
set LE_6 [$SOLE_6 split $SPLIT_6_6]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (7)
set SOLE_7 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_7 [list]
lappend SPLIT_6_7 [$SOLE_7 getParameter -Z -[expr "-$z2 - 70427"]]
set LE_7 [$SOLE_7 split $SPLIT_6_7]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (8)
set SOLE_8 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_8 [list]
lappend SPLIT_6_8 [$SOLE_8 getParameter -Z -[expr "-$z2 - 64712"]]
set LE_8 [$SOLE_8 split $SPLIT_6_8]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (9)
set SOLE_9 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_9 [list]
lappend SPLIT_6_9 [$SOLE_9 getParameter -Z -[expr "-$z2 - 38209"]]
set LE_9 [$SOLE_9 split $SPLIT_6_9]
# SPLIT OF LEADING EDGE -----------------------------------------------------(10)
set SOLE_10 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_10 [list]
lappend SPLIT_6_10 [$SOLE_10 getParameter -Z -[expr "-$z2 - 11427"]]
set LE_10 [$SOLE_10 split $SPLIT_6_10]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (11)
set SOLE_11 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_11 [list]
lappend SPLIT_6_11 [$SOLE_11 getParameter -Z -[expr "-$z2 - 5044"]]
set LE_11 [$SOLE_11 split $SPLIT_6_11]
# SPLIT OF LEADING EDGE ---------------------------------------------------- (12)
set SOLE_12 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
set SPLIT_6_12 [list]
lappend SPLIT_6_12 [$SOLE_12 getParameter -Z -[expr "-$z2 - 2222"]]
set LE_12 [$SOLE_12 split $SPLIT_6_12]

# NUMBER OF CONNECTOR AND SPACING CONSTRAINT ON LEADING EDGE 

set N_C_L_E_13 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
$N_C_L_E_13 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
$N_C_L_E_13 setName LE_13
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_13]]
  set _TMP(PW_1) [$N_C_L_E_13 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $_TMP(PW_1) setEndSpacing 427.72
$_TMP(mode_1) end

set N_C_L_E_12 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
$N_C_L_E_12 setName LE_12
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_12]]
  set _TMP(PW_1) [$N_C_L_E_12 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 427.02
  $_TMP(PW_1) setEndSpacing 796.81
$_TMP(mode_1) end

set N_C_L_E_11 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
$N_C_L_E_11 setName LE_11
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_11]]
  set _TMP(PW_1) [$N_C_L_E_11 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 796.89
  $_TMP(PW_1) setEndSpacing 1107.23
$_TMP(mode_1) end

set N_C_L_E_10 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
$N_C_L_E_10 setName LE_10
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_10]]
  set _TMP(PW_1) [$N_C_L_E_10 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 1107
  $_TMP(PW_1) setEndSpacing 1053
$_TMP(mode_1) end

set N_C_L_E_9 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
$N_C_L_E_9 setName LE_9
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_9]]
  set _TMP(PW_1) [$N_C_L_E_9 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 1053.08
  $_TMP(PW_1) setEndSpacing 1080.58
$_TMP(mode_1) end

set N_C_L_E_8 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
$N_C_L_E_8 setName LE_8
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_8]]
  set _TMP(PW_1) [$N_C_L_E_8 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 1079.97
  $_TMP(PW_1) setEndSpacing 882
$_TMP(mode_1) end

set N_C_L_E_7 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
$N_C_L_E_7 setName LE_7
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_7]]
  set _TMP(PW_1) [$N_C_L_E_7 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 880
  $_TMP(PW_1) setEndSpacing 798.60
$_TMP(mode_1) end

set N_C_L_E_6 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
$N_C_L_E_6 setName LE_6
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_6]]
  set _TMP(PW_1) [$N_C_L_E_6 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 796.37
  $_TMP(PW_1) setEndSpacing 632.31
$_TMP(mode_1) end

set N_C_L_E_5 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
$N_C_L_E_5 setName LE_5
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_5]]
  set _TMP(PW_1) [$N_C_L_E_5 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 632.36
  $_TMP(PW_1) setEndSpacing 622.44
$_TMP(mode_1) end

set N_C_L_E_4 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-1-split-2]
$N_C_L_E_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
$N_C_L_E_4 setName LE_4
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_4]]
  set _TMP(PW_1) [$N_C_L_E_4 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 628.90
  $_TMP(PW_1) setEndSpacing 607.89
$_TMP(mode_1) end

set N_C_L_E_3 [pw::GridEntity getByName con-7-split-1-split-1-split-1-split-2]
$N_C_L_E_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
$N_C_L_E_3 setName LE_3
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_3]]
  set _TMP(PW_1) [$N_C_L_E_3 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 644
  $_TMP(PW_1) setEndSpacing 428.14
$_TMP(mode_1) end

set N_C_L_E_2 [pw::GridEntity getByName con-7-split-1-split-1-split-2]
$N_C_L_E_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
$N_C_L_E_2 setName LE_2
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_2]]
  set _TMP(PW_1) [$N_C_L_E_2 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 426.45
  $_TMP(PW_1) setEndSpacing 222.53
$_TMP(mode_1) end

set N_C_L_E_1 [pw::GridEntity getByName con-7-split-1-split-2]
$N_C_L_E_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_E_1 setName LE_1
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_E_1]]
  set _TMP(PW_1) [$N_C_L_E_1 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 222.75
  $_TMP(PW_1) setEndSpacing 0.0523
$_TMP(mode_1) end

# Create a line BETWEEN TRAILING EDGE

set C_A_L_A_T_E_N_T_R_S [pw::Application begin Create]

  set SELECT_TWO_POINT [pw::SegmentSpline create]
  set POINT_1_TE_IPS [pw::GridEntity getByName con-4-split-2]
  set POINT_2_TE_OPS [pw::GridEntity getByName con-2-split-2-split-1]
  $SELECT_TWO_POINT addPoint [$POINT_1_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT addPoint [$POINT_2_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_1 [pw::Connector create]
  $TENTRS_LINE_1 addSegment $SELECT_TWO_POINT

# Create a line at trailing edge side (2)
  set SELECT_TWO_POINT_2 [pw::SegmentSpline create]
  set POINT_3_TE_IPS [pw::GridEntity getByName con-4-split-1-split-2]
  set POINT_4_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_2 addPoint [$POINT_3_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_2 addPoint [$POINT_4_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_2 [pw::Connector create]
  $TENTRS_LINE_2 addSegment $SELECT_TWO_POINT_2

# Create a line at trailing edge side (3)
  set SELECT_TWO_POINT_3 [pw::SegmentSpline create]
  set POINT_6_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_3 addPoint [$TE_POS_3 getPosition -arc 0]
  $SELECT_TWO_POINT_3 addPoint [$POINT_6_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_3 [pw::Connector create]
  $TENTRS_LINE_3 addSegment $SELECT_TWO_POINT_3

# Create a line at trailing edge side (4)
  set SELECT_TWO_POINT_4 [pw::SegmentSpline create]
  set POINT_7_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-2]
  set POINT_8_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_4 addPoint [$POINT_7_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_4 addPoint [$POINT_8_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_4 [pw::Connector create]
  $TENTRS_LINE_4 addSegment $SELECT_TWO_POINT_4

# Create a line at trailing edge side (5)
  set SELECT_TWO_POINT_5 [pw::SegmentSpline create]
  set POINT_9_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-2]
  set POINT_10_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_5 addPoint [$POINT_9_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_5 addPoint [$POINT_10_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_5 [pw::Connector create]
  $TENTRS_LINE_5 addSegment $SELECT_TWO_POINT_5

 # Create a line at trailing edge side (6) 
  set SELECT_TWO_POINT_6 [pw::SegmentSpline create]
  set POINT_11_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_12_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_6 addPoint [$POINT_11_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_6 addPoint [$POINT_12_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_6 [pw::Connector create]
  $TENTRS_LINE_6 addSegment $SELECT_TWO_POINT_6

 # Create a line at trailing edge side (7) 
  set SELECT_TWO_POINT_7 [pw::SegmentSpline create]
  set POINT_13_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_14_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_7 addPoint [$POINT_13_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_7 addPoint [$POINT_14_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_7 [pw::Connector create]
  $TENTRS_LINE_7 addSegment $SELECT_TWO_POINT_7

 # Create a line at trailing edge side (8)
  set SELECT_TWO_POINT_8 [pw::SegmentSpline create]
  set POINT_15_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_16_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_8 addPoint [$POINT_15_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_8 addPoint [$POINT_16_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_8 [pw::Connector create]
  $TENTRS_LINE_8 addSegment $SELECT_TWO_POINT_8

 # Create a line at trailing edge side (9)
  set SELECT_TWO_POINT_9 [pw::SegmentSpline create]
  set POINT_17_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_18_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_9 addPoint [$POINT_17_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_9 addPoint [$POINT_18_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_9 [pw::Connector create]
  $TENTRS_LINE_9 addSegment $SELECT_TWO_POINT_9

 # Create a line at trailing edge side (10)
  set SELECT_TWO_POINT_10 [pw::SegmentSpline create]
  set POINT_19_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_20_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_10 addPoint [$POINT_19_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_10 addPoint [$POINT_20_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_10 [pw::Connector create]
  $TENTRS_LINE_10 addSegment $SELECT_TWO_POINT_10
  
 # Create a line at trailing edge side (11) 
  set SELECT_TWO_POINT_11 [pw::SegmentSpline create]
  set POINT_21_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-2]
  set POINT_22_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  $SELECT_TWO_POINT_11 addPoint [$POINT_21_TE_IPS getPosition -arc 0]
  $SELECT_TWO_POINT_11 addPoint [$POINT_22_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_11 [pw::Connector create]
  $TENTRS_LINE_11 addSegment $SELECT_TWO_POINT_11

 # Create a line at trailing edge side (12) 
  set SELECT_TWO_POINT_12 [pw::SegmentSpline create]
  set POINT_24_TE_OPS [pw::GridEntity getByName con-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-2-split-1]
  set POINT_23_TE_IPS [pw::GridEntity getByName con-4-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1-split-1]
  $SELECT_TWO_POINT_12 addPoint [$POINT_23_TE_IPS getPosition -arc 1]
  $SELECT_TWO_POINT_12 addPoint [$POINT_24_TE_OPS getPosition -arc 1]
  set TENTRS_LINE_12 [pw::Connector create]
  $TENTRS_LINE_12 addSegment $SELECT_TWO_POINT_12

$C_A_L_A_T_E_N_T_R_S end

# NUMBER OF CONECTOR AND SPACING VALUE (LINE BETWEEN TRAILING EDGE)

set N_C_L_B_T_E [pw::GridEntity getByName con-8]
$N_C_L_B_T_E setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E setName LB_TE
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E]]
  set _TMP(PW_1) [$N_C_L_B_T_E getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.05
  $_TMP(PW_1) setEndSpacing 0.05
$_TMP(mode_1) end

set N_C_L_B_T_E_1 [pw::GridEntity getByName con-12]
$N_C_L_B_T_E_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_1 setName LB_TE_1
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_1]]
  set _TMP(PW_1) [$N_C_L_B_T_E_1 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.05
  $_TMP(PW_1) setEndSpacing 0.05
$_TMP(mode_1) end

set N_C_L_B_T_E_2 [pw::GridEntity getByName con-13]
$N_C_L_B_T_E_2 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_2 setName LB_TE_2
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_2]]
  set _TMP(PW_1) [$N_C_L_B_T_E_2 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.05
  $_TMP(PW_1) setEndSpacing 0.05
$_TMP(mode_1) end

set N_C_L_B_T_E_3 [pw::GridEntity getByName con-14]
$N_C_L_B_T_E_3 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_3 setName LB_TE_3
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_3]]
  set _TMP(PW_1) [$N_C_L_B_T_E_3 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.07
  $_TMP(PW_1) setEndSpacing 0.07
$_TMP(mode_1) end

set N_C_L_B_T_E_4 [pw::GridEntity getByName con-15]
$N_C_L_B_T_E_4 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_4 setName LB_TE_4
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_4]]
  set _TMP(PW_1) [$N_C_L_B_T_E_4 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.15
  $_TMP(PW_1) setEndSpacing 0.15
$_TMP(mode_1) end

set N_C_L_B_T_E_5 [pw::GridEntity getByName con-16]
$N_C_L_B_T_E_5 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_5 setName LB_TE_5
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_5]]
  set _TMP(PW_1) [$N_C_L_B_T_E_5 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.25
  $_TMP(PW_1) setEndSpacing 0.25
$_TMP(mode_1) end

set N_C_L_B_T_E_6 [pw::GridEntity getByName con-17]
$N_C_L_B_T_E_6 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_6 setName LB_TE_6
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_6]]
  set _TMP(PW_1) [$N_C_L_B_T_E_6 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.3
  $_TMP(PW_1) setEndSpacing 0.3
$_TMP(mode_1) end

set N_C_L_B_T_E_7 [pw::GridEntity getByName con-18]
$N_C_L_B_T_E_7 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_7 setName LB_TE_7
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_7]]
  set _TMP(PW_1) [$N_C_L_B_T_E_7 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.7
  $_TMP(PW_1) setEndSpacing 0.7
$_TMP(mode_1) end

set N_C_L_B_T_E_8 [pw::GridEntity getByName con-19]
$N_C_L_B_T_E_8 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_8 setName LB_TE_8
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_8]]
  set _TMP(PW_1) [$N_C_L_B_T_E_8 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.695
  $_TMP(PW_1) setEndSpacing 0.695
$_TMP(mode_1) end

set N_C_L_B_T_E_9 [pw::GridEntity getByName con-20]
$N_C_L_B_T_E_9 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_9 setName LB_TE_9
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_9]]
  set _TMP(PW_1) [$N_C_L_B_T_E_9 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.25
  $_TMP(PW_1) setEndSpacing 0.25
$_TMP(mode_1) end

set N_C_L_B_T_E_10 [pw::GridEntity getByName con-21]
$N_C_L_B_T_E_10 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_10 setName LB_TE_10
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_10]]
  set _TMP(PW_1) [$N_C_L_B_T_E_10 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.6
  $_TMP(PW_1) setEndSpacing 0.6
$_TMP(mode_1) end

set N_C_L_B_T_E_11 [pw::GridEntity getByName con-22]
$N_C_L_B_T_E_11 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_11 setName LB_TE_11
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_11]]
  set _TMP(PW_1) [$N_C_L_B_T_E_11 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.6
  $_TMP(PW_1) setEndSpacing 0.6
$_TMP(mode_1) end

set N_C_L_B_T_E_12 [pw::GridEntity getByName con-23]
$N_C_L_B_T_E_12 setDimension [expr "$NUMBER_OF_CONNECTORS"]
$N_C_L_B_T_E_12 setName LB_TE_12
set _TMP(mode_1) [pw::Application begin Modify [list $N_C_L_B_T_E_12]]
  set _TMP(PW_1) [$N_C_L_B_T_E_12 getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.4
  $_TMP(PW_1) setEndSpacing 0.4
$_TMP(mode_1) end

# CREATE A STRUCTURE DOMAIN ON TRAILING EDGE
# S_L_E_B_P_I_A_O_S = SELECT_A_LEADING_EDGE_BETWEEN_PRESSURE_INLET_AND_OUTLET_SIDE 
# S_L_E_P_O_S = SELECT_A_LEADING_EDGE_PRESSURE_OUTLET_SIDE
# S_L_E_P_I_S = SELECT_A_LEADING_EDGE_PRESSURE_INLET_SIDE

set CREATE_A_STRUCTURE_DOMAIN_OF_TRAILING_EDGE_SIDE [pw::Application begin Create]

set S_L_E_B_P_I_A_O_S_1 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_1 addConnector $N_C_L_B_T_E
set S_L_E_P_O_S_1 [pw::Edge create];        $S_L_E_P_O_S_1 addConnector $N_C_T_P_O_S_1
set S_L_E_B_P_I_A_O_S_2 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_2 addConnector $N_C_L_B_T_E_1
set S_L_E_P_I_S_1 [pw::Edge create];        $S_L_E_P_I_S_1 addConnector $TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE
set DOM_1 [pw::DomainStructured create]
$DOM_1 addEdge $S_L_E_B_P_I_A_O_S_1;                 $DOM_1 addEdge $S_L_E_P_O_S_1; 
$DOM_1 addEdge $S_L_E_B_P_I_A_O_S_2;                 $DOM_1 addEdge $S_L_E_P_I_S_1
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_1 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_1 setName TE_DOM_1

set S_L_E_B_P_I_A_O_S_2 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_2 addConnector $N_C_L_B_T_E_1
set S_L_E_P_O_S_2 [pw::Edge create];        $S_L_E_P_O_S_2 addConnector $N_C_T_P_O_S_2
set S_L_E_B_P_I_A_O_S_3 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_3 addConnector $N_C_L_B_T_E_2
set S_L_E_P_I_S_2 [pw::Edge create];        $S_L_E_P_I_S_2 addConnector $TE_P_IS_2
set DOM_2 [pw::DomainStructured create]
$DOM_2 addEdge $S_L_E_B_P_I_A_O_S_2;                 $DOM_2 addEdge $S_L_E_P_O_S_2; 
$DOM_2 addEdge $S_L_E_B_P_I_A_O_S_3;                 $DOM_2 addEdge $S_L_E_P_I_S_2
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_2 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_2 setName TE_DOM_2

set S_L_E_B_P_I_A_O_S_3 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_3 addConnector $N_C_L_B_T_E_2
set S_L_E_P_O_S_3 [pw::Edge create];        $S_L_E_P_O_S_3 addConnector $N_C_T_P_O_S_3
set S_L_E_B_P_I_A_O_S_4 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_4 addConnector $N_C_L_B_T_E_3
set S_L_E_P_I_S_3 [pw::Edge create];        $S_L_E_P_I_S_3 addConnector $TE_P_IS_3
set DOM_3 [pw::DomainStructured create]
$DOM_3 addEdge $S_L_E_B_P_I_A_O_S_3;                 $DOM_3 addEdge $S_L_E_P_O_S_3; 
$DOM_3 addEdge $S_L_E_B_P_I_A_O_S_4;                 $DOM_3 addEdge $S_L_E_P_I_S_3
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_3 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_3 setName TE_DOM_3

set S_L_E_B_P_I_A_O_S_4 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_4 addConnector $N_C_L_B_T_E_3
set S_L_E_P_O_S_4 [pw::Edge create];        $S_L_E_P_O_S_4 addConnector $N_C_T_P_O_S_4
set S_L_E_B_P_I_A_O_S_5 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_5 addConnector $N_C_L_B_T_E_4
set S_L_E_P_I_S_4 [pw::Edge create];        $S_L_E_P_I_S_4 addConnector $TE_P_IS_4
set DOM_4 [pw::DomainStructured create]
$DOM_4 addEdge $S_L_E_B_P_I_A_O_S_4;                 $DOM_4 addEdge $S_L_E_P_O_S_4; 
$DOM_4 addEdge $S_L_E_B_P_I_A_O_S_5;                 $DOM_4 addEdge $S_L_E_P_I_S_4
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_4 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_4 setName TE_DOM_4

set S_L_E_B_P_I_A_O_S_5 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_5 addConnector $N_C_L_B_T_E_4
set S_L_E_P_O_S_5 [pw::Edge create];        $S_L_E_P_O_S_5 addConnector $N_C_T_P_O_S_5
set S_L_E_B_P_I_A_O_S_6 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_6 addConnector $N_C_L_B_T_E_5
set S_L_E_P_I_S_5 [pw::Edge create];        $S_L_E_P_I_S_5 addConnector $TE_P_IS_5
set DOM_5 [pw::DomainStructured create]
$DOM_5 addEdge $S_L_E_B_P_I_A_O_S_5;                 $DOM_5 addEdge $S_L_E_P_O_S_5; 
$DOM_5 addEdge $S_L_E_B_P_I_A_O_S_6;                 $DOM_5 addEdge $S_L_E_P_I_S_5
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_5 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_5 setName TE_DOM_5

set S_L_E_B_P_I_A_O_S_6 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_6 addConnector $N_C_L_B_T_E_5
set S_L_E_P_O_S_6 [pw::Edge create];        $S_L_E_P_O_S_6 addConnector $N_C_T_P_O_S_6
set S_L_E_B_P_I_A_O_S_7 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_7 addConnector $N_C_L_B_T_E_6
set S_L_E_P_I_S_6 [pw::Edge create];        $S_L_E_P_I_S_6 addConnector $TE_P_IS_6
set DOM_6 [pw::DomainStructured create]
$DOM_6 addEdge $S_L_E_B_P_I_A_O_S_6;                 $DOM_6 addEdge $S_L_E_P_O_S_6; 
$DOM_6 addEdge $S_L_E_B_P_I_A_O_S_7;                 $DOM_6 addEdge $S_L_E_P_I_S_6
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_6 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_6 setName TE_DOM_6

set S_L_E_B_P_I_A_O_S_7 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_7 addConnector $N_C_L_B_T_E_6
set S_L_E_P_O_S_7 [pw::Edge create];        $S_L_E_P_O_S_7 addConnector $N_C_T_P_O_S_7
set S_L_E_B_P_I_A_O_S_8 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_8 addConnector $N_C_L_B_T_E_7
set S_L_E_P_I_S_7 [pw::Edge create];        $S_L_E_P_I_S_7 addConnector $TE_P_IS_7
set DOM_7 [pw::DomainStructured create]
$DOM_7 addEdge $S_L_E_B_P_I_A_O_S_7;                 $DOM_7 addEdge $S_L_E_P_O_S_7; 
$DOM_7 addEdge $S_L_E_B_P_I_A_O_S_8;                 $DOM_7 addEdge $S_L_E_P_I_S_7
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_7 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_7 setName TE_DOM_7

set S_L_E_B_P_I_A_O_S_8 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_8 addConnector $N_C_L_B_T_E_7
set S_L_E_P_O_S_8 [pw::Edge create];        $S_L_E_P_O_S_8 addConnector $N_C_T_P_O_S_8
set S_L_E_B_P_I_A_O_S_9 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_9 addConnector $N_C_L_B_T_E_8
set S_L_E_P_I_S_8 [pw::Edge create];        $S_L_E_P_I_S_8 addConnector $TE_P_IS_8
set DOM_8 [pw::DomainStructured create]
$DOM_8 addEdge $S_L_E_B_P_I_A_O_S_8;                 $DOM_8 addEdge $S_L_E_P_O_S_8; 
$DOM_8 addEdge $S_L_E_B_P_I_A_O_S_9;                 $DOM_8 addEdge $S_L_E_P_I_S_8
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_8 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_8 setName TE_DOM_8

set S_L_E_B_P_I_A_O_S_9 [pw::Edge create];  $S_L_E_B_P_I_A_O_S_9 addConnector $N_C_L_B_T_E_8
set S_L_E_P_O_S_9 [pw::Edge create];        $S_L_E_P_O_S_9 addConnector $N_C_T_P_O_S_9
set S_L_E_B_P_I_A_O_S_10 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_10 addConnector $N_C_L_B_T_E_9
set S_L_E_P_I_S_9 [pw::Edge create];        $S_L_E_P_I_S_9 addConnector $TE_P_IS_9
set DOM_9 [pw::DomainStructured create]
$DOM_9 addEdge $S_L_E_B_P_I_A_O_S_9;                 $DOM_9 addEdge $S_L_E_P_O_S_9; 
$DOM_9 addEdge $S_L_E_B_P_I_A_O_S_10;                $DOM_9 addEdge $S_L_E_P_I_S_9
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_9 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_9 setName TE_DOM_9

set S_L_E_B_P_I_A_O_S_10 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_10 addConnector $N_C_L_B_T_E_9
set S_L_E_P_O_S_10 [pw::Edge create];       $S_L_E_P_O_S_10 addConnector $N_C_T_P_O_S_10
set S_L_E_B_P_I_A_O_S_11 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_11 addConnector $N_C_L_B_T_E_10
set S_L_E_P_I_S_10 [pw::Edge create];       $S_L_E_P_I_S_10 addConnector $TE_P_IS_10
set DOM_10 [pw::DomainStructured create]
$DOM_10 addEdge $S_L_E_B_P_I_A_O_S_10;                $DOM_10 addEdge $S_L_E_P_O_S_10; 
$DOM_10 addEdge $S_L_E_B_P_I_A_O_S_11;                $DOM_10 addEdge $S_L_E_P_I_S_10
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_10 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_10 setName TE_DOM_10

set S_L_E_B_P_I_A_O_S_11 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_11 addConnector $N_C_L_B_T_E_10
set S_L_E_P_O_S_11 [pw::Edge create];       $S_L_E_P_O_S_11 addConnector $N_C_T_P_O_S_11
set S_L_E_B_P_I_A_O_S_12 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_12 addConnector $N_C_L_B_T_E_11
set S_L_E_P_I_S_11 [pw::Edge create];       $S_L_E_P_I_S_11 addConnector $TE_P_IS_11
set DOM_11 [pw::DomainStructured create]
$DOM_11 addEdge $S_L_E_B_P_I_A_O_S_11;                $DOM_11 addEdge $S_L_E_P_O_S_11; 
$DOM_11 addEdge $S_L_E_B_P_I_A_O_S_12;                $DOM_11 addEdge $S_L_E_P_I_S_11
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_11 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_11 setName TE_DOM_11

set S_L_E_B_P_I_A_O_S_12 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_12 addConnector $N_C_L_B_T_E_11
set S_L_E_P_O_S_12 [pw::Edge create];       $S_L_E_P_O_S_12 addConnector $N_C_T_P_O_S_12
set S_L_E_B_P_I_A_O_S_13 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_13 addConnector $N_C_L_B_T_E_12
set S_L_E_P_I_S_12 [pw::Edge create];       $S_L_E_P_I_S_12 addConnector $TE_P_IS_12
set DOM_12 [pw::DomainStructured create]
$DOM_12 addEdge $S_L_E_B_P_I_A_O_S_12;                $DOM_12 addEdge $S_L_E_P_O_S_12; 
$DOM_12 addEdge $S_L_E_B_P_I_A_O_S_13;                $DOM_12 addEdge $S_L_E_P_I_S_12
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_12 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_12 setName TE_DOM_12

set S_L_E_B_P_I_A_O_S_13 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_13 addConnector $N_C_L_B_T_E_12
set S_L_E_P_O_S_13 [pw::Edge create];       $S_L_E_P_O_S_13 addConnector $TE_P_OS_12
set S_L_E_B_P_I_A_O_S_14 [pw::Edge create]; $S_L_E_B_P_I_A_O_S_14 addConnector $T_E_T_S
set S_L_E_P_I_S_13 [pw::Edge create];       $S_L_E_P_I_S_13 addConnector $TE_P_IS_13
set DOM_13 [pw::DomainStructured create]
$DOM_13 addEdge $S_L_E_B_P_I_A_O_S_13;                $DOM_13 addEdge $S_L_E_P_O_S_13; 
$DOM_13 addEdge $S_L_E_B_P_I_A_O_S_14;                $DOM_13 addEdge $S_L_E_P_I_S_13
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_13 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_13 setName TE_DOM_13
$CREATE_A_STRUCTURE_DOMAIN_OF_TRAILING_EDGE_SIDE end

set AREA_SOLVE_DOM_7 [pw::Application begin EllipticSolver [list $DOM_7]]
$AREA_SOLVE_DOM_7 setActiveSubGrids $DOM_7 [list]
$AREA_SOLVE_DOM_7 run 50
$AREA_SOLVE_DOM_7 end

# CREATE A DOMAIN PRESSURE INLET SIDE AIRFOIL
# S_R_S_P_I_AF = SELECT ROOT SIDE PRESSURE INLET AIRFOIL 
# S_P_I_T_E = SELECT PRESSURE INLET TRAILING EDGE
# S_T_S_P_I_AF = SELECT TIP SIDE PRESSURE INLET AIRFOIL 
# S_P_I_L_E = SELECT PRESSURE INLET LEADING EDGE

set CREATE_A_STRUCTURE_DOMAIN_OF_PRESSURE_INLET_SIDE [pw::Application begin Create]
set S_R_S_P_I_AF [pw::Edge create];  $S_R_S_P_I_AF addConnector $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL
set S_P_I_T_E [pw::Edge create]
$S_P_I_T_E addConnector $TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE; $S_P_I_T_E addConnector $TE_P_IS_2
$S_P_I_T_E addConnector $TE_P_IS_3;   $S_P_I_T_E addConnector $TE_P_IS_4
$S_P_I_T_E addConnector $TE_P_IS_5;   $S_P_I_T_E addConnector $TE_P_IS_6
$S_P_I_T_E addConnector $TE_P_IS_7;   $S_P_I_T_E addConnector $TE_P_IS_8
$S_P_I_T_E addConnector $TE_P_IS_9;   $S_P_I_T_E addConnector $TE_P_IS_10
$S_P_I_T_E addConnector $TE_P_IS_11;  $S_P_I_T_E addConnector $TE_P_IS_12
$S_P_I_T_E addConnector $TE_P_IS_13
set S_T_S_P_I_AF [pw::Edge create];   $S_T_S_P_I_AF addConnector $P_O_T_S_L_E
set S_P_I_L_E [pw::Edge create]
$S_P_I_L_E addConnector $N_C_L_E_1;   $S_P_I_L_E addConnector $N_C_L_E_2
$S_P_I_L_E addConnector $N_C_L_E_3;   $S_P_I_L_E addConnector $N_C_L_E_4
$S_P_I_L_E addConnector $N_C_L_E_5;   $S_P_I_L_E addConnector $N_C_L_E_6
$S_P_I_L_E addConnector $N_C_L_E_7;   $S_P_I_L_E addConnector $N_C_L_E_8
$S_P_I_L_E addConnector $N_C_L_E_9;   $S_P_I_L_E addConnector $N_C_L_E_10
$S_P_I_L_E addConnector $N_C_L_E_11;  $S_P_I_L_E addConnector $N_C_L_E_12
$S_P_I_L_E addConnector $N_C_L_E_13
set DOM_14 [pw::DomainStructured create]
$DOM_14 addEdge $S_R_S_P_I_AF;          $DOM_14 addEdge $S_P_I_T_E;
$DOM_14 addEdge $S_T_S_P_I_AF;          $DOM_14 addEdge $S_P_I_L_E;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_14 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_14 setName PI_AF_DOM_14
$CREATE_A_STRUCTURE_DOMAIN_OF_PRESSURE_INLET_SIDE end

# CREATE A DOMAIN PRESSURE OUTLET SIDE AIRFOIL
# S_R_S_P_O_AF = SELECT ROOT SIDE PRESSURE OUTLET AIRFOIL 
# S_P_O_T_E = SELECT PRESSURE OUTLET TRAILING EDGE
# S_T_S_P_O_AF = SELECT TIP SIDE PRESSURE OUTLET AIRFOIL 
# S_P_O_L_E = SELECT PRESSURE OUTLET LEADING EDGE

set CREATE_A_STRUCTURE_DOMAIN_OF_PRESSURE_OUTLET_SIDE [pw::Application begin Create]
set S_R_S_P_O_AF [pw::Edge create];  $S_R_S_P_O_AF addConnector $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL
set S_P_O_T_E [pw::Edge create]
$S_P_O_T_E addConnector $N_C_T_P_O_S_1;  $S_P_O_T_E addConnector $N_C_T_P_O_S_2
$S_P_O_T_E addConnector $N_C_T_P_O_S_3;  $S_P_O_T_E addConnector $N_C_T_P_O_S_4
$S_P_O_T_E addConnector $N_C_T_P_O_S_5;  $S_P_O_T_E addConnector $N_C_T_P_O_S_6
$S_P_O_T_E addConnector $N_C_T_P_O_S_7;  $S_P_O_T_E addConnector $N_C_T_P_O_S_8
$S_P_O_T_E addConnector $N_C_T_P_O_S_9;  $S_P_O_T_E addConnector $N_C_T_P_O_S_10
$S_P_O_T_E addConnector $N_C_T_P_O_S_11; $S_P_O_T_E addConnector $N_C_T_P_O_S_12
$S_P_O_T_E addConnector $TE_P_OS_12
set S_T_S_P_O_AF [pw::Edge create];    $S_T_S_P_O_AF addConnector $P_I_T_S
set S_P_O_L_E [pw::Edge create]
$S_P_O_L_E addConnector $N_C_L_E_1;    $S_P_O_L_E addConnector $N_C_L_E_2
$S_P_O_L_E addConnector $N_C_L_E_3;    $S_P_O_L_E addConnector $N_C_L_E_4
$S_P_O_L_E addConnector $N_C_L_E_5;    $S_P_O_L_E addConnector $N_C_L_E_6
$S_P_O_L_E addConnector $N_C_L_E_7;    $S_P_O_L_E addConnector $N_C_L_E_8
$S_P_O_L_E addConnector $N_C_L_E_9;    $S_P_O_L_E addConnector $N_C_L_E_10
$S_P_O_L_E addConnector $N_C_L_E_11;   $S_P_O_L_E addConnector $N_C_L_E_12
$S_P_O_L_E addConnector $N_C_L_E_13
set DOM_15 [pw::DomainStructured create]
$DOM_15 addEdge $S_R_S_P_O_AF;          $DOM_15 addEdge $S_P_O_T_E;
$DOM_15 addEdge $S_T_S_P_O_AF;          $DOM_15 addEdge $S_P_O_L_E;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_15 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_15 setName PO_AF_DOM_15
$CREATE_A_STRUCTURE_DOMAIN_OF_PRESSURE_OUTLET_SIDE end

# CREATE A DOMAIN ROOT SIDE
# S_A_E = SELECT A EDGES

set CREATE_A_DOMAIN_ROOT_SIDE [pw::Application begin Create]
set S_A_E [pw::Edge create]
$S_A_E addConnector $N_C_L_B_T_E;  $S_A_E addConnector $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL
$S_A_E addConnector $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL
set dom_16 [pw::DomainUnstructured create]
$dom_16 addEdge $S_A_E
set CHANGE_A_NAME_OF_DOMAIN_ROOTSIDE_DOMAIN_16 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_DOMAIN_ROOTSIDE_DOMAIN_16 setName RS_DOM_16
$CREATE_A_DOMAIN_ROOT_SIDE end

# CREATE A DOMAIN TIP SIDE
# S_A_E_T = SELECT A EDGES TIPSIDE

set CREATE_A_DOMAIN_TIP_SIDE [pw::Application begin Create]
set S_A_E_T [pw::Edge create]
$S_A_E_T addConnector $T_E_T_S;  $S_A_E_T addConnector $P_O_T_S_L_E
$S_A_E_T addConnector $P_I_T_S
set dom_17 [pw::DomainUnstructured create]
$dom_17 addEdge $S_A_E_T
set CHANGE_A_NAME_OF_DOMAIN_TIPSIDE_DOMAIN_17 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_DOMAIN_TIPSIDE_DOMAIN_17 setName TS_DOM_17
$CREATE_A_DOMAIN_TIP_SIDE end

# APPLIED T-REX

set TREX_1 [pw::Application begin UnstructuredSolver [list $dom_16 $dom_17]]
set T1 [pw::TRexCondition create]
set T1 [pw::TRexCondition getByName bc-2]
$T1 setConditionType Wall
$T1 setValue 0.05
$T1 apply [list [list $dom_16 $N_C_L_B_T_E Same] [list $dom_16 $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL Opposite] [list $dom_16 $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL Same]]
$T1 apply [list [list $dom_17 $T_E_T_S Same] [list $dom_17 $P_O_T_S_L_E Same] [list $dom_17 $P_I_T_S Same]]
$dom_16 setUnstructuredSolverAttribute TRexGrowthRate 1.2; $dom_17 setUnstructuredSolverAttribute TRexGrowthRate 1.2
$dom_16 setUnstructuredSolverAttribute TRexMaximumLayers 2000; $dom_17 setUnstructuredSolverAttribute TRexMaximumLayers 2000
$dom_16 setUnstructuredSolverAttribute TRexCellType TriangleQuad; $dom_17 setUnstructuredSolverAttribute TRexCellType TriangleQuad
$dom_16 setUnstructuredSolverAttribute Algorithm AdvancingFrontOrtho; $dom_17 setUnstructuredSolverAttribute Algorithm AdvancingFrontOrtho
$dom_16 setUnstructuredSolverAttribute IsoCellType TriangleQuad; $dom_17 setUnstructuredSolverAttribute IsoCellType TriangleQuad
$TREX_1 run Initialize
$TREX_1 end

########################################################################################################
# END SCRIPT OF WIND TUBINE BLADE
########################################################################################################

#######################################################################################################
#######################################################################################################
# SCRIPT OF CREATE A STRUCTURE CYLINDER AROUND WIND TURBINE BLADE
#######################################################################################################
#######################################################################################################

# ----------------------------------------------------------------------------------------------
# CREATE A CIRCLE AT ROOT SIDE
# ----------------------------------------------------------------------------------------------

set CREATE_A_CIRCLE_AT_ROOT_SIDE [pw::Application begin Create]
set SELECT_A_CENTER_POINT [pw::SegmentSpline create]
set SECOUND_POINT [pw::SegmentSpline create]
set THIRD_POINT [pw::SegmentSpline create]
$SELECT_A_CENTER_POINT addPoint "$x1 $y1 $z1"
$SECOUND_POINT addPoint "-[expr $CYLINDER_RADIUS - 181.8112 + $x1] -[expr $CYLINDER_RADIUS - 3663.9399 + $y1] $z1"
$THIRD_POINT addPoint "[expr $CYLINDER_RADIUS - 1313.7057 + $x1] -[expr $CYLINDER_RADIUS - 1621.9481 + $y1] $z1"
set ADD_CP [pw::Connector create]
set ADD_SP [pw::Connector create]
set ADD_TP [pw::Connector create]
$ADD_CP addSegment $SELECT_A_CENTER_POINT
$ADD_SP addSegment $SECOUND_POINT
$ADD_TP addSegment $THIRD_POINT

# CREATE 179 DEGREE CICLE
set POINT_USE_TO_CREATE_A_CIRCLE_179 [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_179 addPoint [$ADD_SP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_179 addPoint [$ADD_CP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_179 setEndAngle 179 {0 0 -1}
set CREATE_FIRST_179_DEGREE_CIRCLE [pw::Connector create]
$CREATE_FIRST_179_DEGREE_CIRCLE addSegment $POINT_USE_TO_CREATE_A_CIRCLE_179

# CREATE A 122 DEGREE CIRCLE
set POINT_USE_TO_CREATE_A_CIRCLE_122 [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_122 addPoint [$ADD_SP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_122 addPoint [$ADD_CP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_122 setEndAngle 122 {0 0 1}
set CREATE_FIRST_122_DEGREE_CIRCLE [pw::Connector create]
$CREATE_FIRST_122_DEGREE_CIRCLE addSegment $POINT_USE_TO_CREATE_A_CIRCLE_122

# CREATE A 59 DEGREE CIRCLE
set POINT_USE_TO_CREATE_A_CIRCLE_59 [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_59 addPoint [$ADD_TP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_59 addPoint [$ADD_CP getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_59 setEndAngle 59 {0 0 1}
set CREATE_FIRST_59_DEGREE_CIRCLE [pw::Connector create]
$CREATE_FIRST_59_DEGREE_CIRCLE addSegment $POINT_USE_TO_CREATE_A_CIRCLE_59
$CREATE_A_CIRCLE_AT_ROOT_SIDE end

# ----------------------------------------------------------------------------------------------
# NUMBER OF CONNECOTRS AND SPACING CONSTRAINT VALUE
# ----------------------------------------------------------------------------------------------

# FOR 179 DEGREE CICLE
$CREATE_FIRST_179_DEGREE_CIRCLE setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_179_DEGREE_CIRCLE]]
  set _TMP(PW_1) [$CREATE_FIRST_179_DEGREE_CIRCLE getDistribution 1]
  $_TMP(PW_1) setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_179_DEGREE_CIRCLE setName RS_179_DEGREE_CIRCLE

# FOR 122 DEGREE CICLE
$CREATE_FIRST_122_DEGREE_CIRCLE setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_122_DEGREE_CIRCLE]]
  set _TMP(PW_1) [$CREATE_FIRST_122_DEGREE_CIRCLE getDistribution 1]
  $_TMP(PW_1) setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_122_DEGREE_CIRCLE setName RS_122_DEGREE_CIRCLE

# FOR 59 DEGREE CIRCLE
$CREATE_FIRST_59_DEGREE_CIRCLE setDimension [expr "$NUMBER_OF_CONNECTORS"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_59_DEGREE_CIRCLE]]
  set _TMP(PW_1) [$CREATE_FIRST_59_DEGREE_CIRCLE getDistribution 1]
  $_TMP(PW_1) setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_59_DEGREE_CIRCLE setName RS_59_DEGREE_CIRCLE

# ----------------------------------------------------------------------------------------------
# CREATE A CIRCLE AT TIP SIDE
# ----------------------------------------------------------------------------------------------

set CREATE_A_CIRCLE_AT_TIP_SIDE [pw::Application begin Create]
set SELECT_A_CENTER_POINT_TS [pw::SegmentSpline create]
set SECOUND_POINT_TS [pw::SegmentSpline create]
set THIRD_POINT_TS [pw::SegmentSpline create]
$SELECT_A_CENTER_POINT_TS addPoint "$x1 0 $z2"
$SECOUND_POINT_TS addPoint "-[expr $CYLINDER_RADIUS - 181.8112 + $x1] -[expr $CYLINDER_RADIUS - 3663.9399 + $y1] $z2"
$THIRD_POINT_TS addPoint "[expr $CYLINDER_RADIUS - 1313.7057 + $x1] -[expr $CYLINDER_RADIUS - 1621.9481 + $y1] $z2"
set ADD_CP_TS [pw::Connector create]
set ADD_SP_TS [pw::Connector create]
set ADD_TP_TS [pw::Connector create]
$ADD_CP_TS addSegment $SELECT_A_CENTER_POINT_TS
$ADD_SP_TS addSegment $SECOUND_POINT_TS
$ADD_TP_TS addSegment $THIRD_POINT_TS
# CREATE 179 DEGREE CICLE
set POINT_USE_TO_CREATE_A_CIRCLE_179_TS [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_179_TS addPoint [$ADD_SP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_179_TS addPoint [$ADD_CP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_179_TS setEndAngle 179 {0 0 -1}
set CREATE_FIRST_179_DEGREE_CIRCLE_TS [pw::Connector create]
$CREATE_FIRST_179_DEGREE_CIRCLE_TS addSegment $POINT_USE_TO_CREATE_A_CIRCLE_179_TS

# CREATE A 122 DEGREE CIRCLE
set POINT_USE_TO_CREATE_A_CIRCLE_122_TS [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_122_TS addPoint [$ADD_SP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_122_TS addPoint [$ADD_CP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_122_TS setEndAngle 122 {0 0 1}
set CREATE_FIRST_122_DEGREE_CIRCLE_TS [pw::Connector create]
$CREATE_FIRST_122_DEGREE_CIRCLE_TS addSegment $POINT_USE_TO_CREATE_A_CIRCLE_122_TS

# CREATE A 59 DEGREE CIRCLE
set POINT_USE_TO_CREATE_A_CIRCLE_59_TS [pw::SegmentCircle create]
$POINT_USE_TO_CREATE_A_CIRCLE_59_TS addPoint [$ADD_TP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_59_TS addPoint [$ADD_CP_TS getPosition -arc 0]
$POINT_USE_TO_CREATE_A_CIRCLE_59_TS setEndAngle 59 {0 0 1}
set CREATE_FIRST_59_DEGREE_CIRCLE_TS [pw::Connector create]
$CREATE_FIRST_59_DEGREE_CIRCLE_TS addSegment $POINT_USE_TO_CREATE_A_CIRCLE_59_TS
$CREATE_A_CIRCLE_AT_TIP_SIDE end

# ----------------------------------------------------------------------------------------------
# NUMBER OF CONNECOTORS AND SPACING VALUE
# ----------------------------------------------------------------------------------------------

# FOR 179 DEGREE CICLE
$CREATE_FIRST_179_DEGREE_CIRCLE_TS setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_179_DEGREE_CIRCLE_TS]]
  set _TMP(PW_1) [$CREATE_FIRST_179_DEGREE_CIRCLE_TS getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.13
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_179_DEGREE_CIRCLE_TS setName TS_179_DEGREE_CIRCLE

# FOR 122 DEGREE CICLE
$CREATE_FIRST_122_DEGREE_CIRCLE_TS setDimension [expr "2*$NUMBER_OF_CONNECTORS + 25"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_122_DEGREE_CIRCLE_TS]]
  set _TMP(PW_1) [$CREATE_FIRST_122_DEGREE_CIRCLE_TS getDistribution 1]
  $_TMP(PW_1) setBeginSpacing 0.13
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_122_DEGREE_CIRCLE_TS setName TS_122_DEGREE_CIRCLE

# FOR 59 DEGREE CIRCLE
$CREATE_FIRST_59_DEGREE_CIRCLE_TS setDimension [expr "$NUMBER_OF_CONNECTORS"]
set _TMP(mode_1) [pw::Application begin Modify [list $CREATE_FIRST_59_DEGREE_CIRCLE_TS]]
  set _TMP(PW_1) [$CREATE_FIRST_59_DEGREE_CIRCLE_TS getDistribution 1]
  $_TMP(PW_1) setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $_TMP(PW_1) setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$_TMP(mode_1) end
$CREATE_FIRST_59_DEGREE_CIRCLE_TS setName TS_59_DEGREE_CIRCLE

# ----------------------------------------------------------------------------------------------
# CREATE A LINE BETWEEN ROOTSIDE AND TIP SIDE CIRCLE
#C_L = CREATE A LINE
# ----------------------------------------------------------------------------------------------

set C_A_L_B_R_A_T_S_C [pw::Application begin Create]
set FOURTH_POINT [pw::SegmentSpline create]
set FOURTH_POINT_TS [pw::SegmentSpline create]
$FOURTH_POINT addPoint "[expr $CYLINDER_RADIUS - 205.8625 + $x1] [expr $CYLINDER_RADIUS - 3580.0544 + $y1] $z1"
$FOURTH_POINT_TS addPoint "[expr $CYLINDER_RADIUS - 205.8625 + $x1] [expr $CYLINDER_RADIUS - 3580.0544 + $y1] $z2"

# LINE_1
set LINE_1 [pw::SegmentSpline create]
$LINE_1 addPoint [$SECOUND_POINT getPosition -arc 0]
$LINE_1 addPoint [$SECOUND_POINT_TS getPosition -arc 0]
set C_L_1 [pw::Connector create]
$C_L_1 addSegment $LINE_1
$C_L_1 setName LINE_1

# LINE_2
set LINE_2 [pw::SegmentSpline create]
$LINE_2 addPoint [$THIRD_POINT getPosition -arc 0]
$LINE_2 addPoint [$THIRD_POINT_TS getPosition -arc 0]
set C_L_2 [pw::Connector create]
$C_L_2 addSegment $LINE_2
$C_L_2 setName LINE_2

# LINE_3
set LINE_3 [pw::SegmentSpline create]
$LINE_3 addPoint [$FOURTH_POINT getPosition -arc 0]
$LINE_3 addPoint [$FOURTH_POINT_TS getPosition -arc 0]
set C_L_3 [pw::Connector create]
$C_L_3 addSegment $LINE_3
$C_L_3 setName LINE_3
$C_A_L_B_R_A_T_S_C end

# SPLIT LINE_1
# S_L_1 = SPLIT LINE 1
# S_C_L1 = SPACING CONSTRATIN LINE1 
# S_S_C_L1_1 = SELECT SPACING CONSTRATIN LINE1 
# NUMBER OF CONNECTORS AND SPACING VALUE

set S_L_1_1 [list]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 95378"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 94157"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 90618"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 83928"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 79546"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 75402"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 70427"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 64712"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 38209"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 11427"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 5044"]]
lappend S_L_1_1 [$C_L_1 getParameter -Z -[expr "-$z2 - 2222"]]

set L_S_1_1 [$C_L_1 split $S_L_1_1]
set LINE_1_SPLIT_1 [pw::GridEntity getByName LINE_1-split-1]
$LINE_1_SPLIT_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
set S_C_L1_1 [pw::Application begin Modify [list $LINE_1_SPLIT_1]]
  set S_S_C_L1_1 [$LINE_1_SPLIT_1 getDistribution 1]
  $S_S_C_L1_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_L1_1 setEndSpacing 222.75
$S_C_L1_1 end

set LINE_1_SPLIT_2 [pw::GridEntity getByName LINE_1-split-2]
$LINE_1_SPLIT_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
set S_C_L1_2 [pw::Application begin Modify [list $LINE_1_SPLIT_2]]
  set S_S_C_L1_2 [$LINE_1_SPLIT_2 getDistribution 1]
  $S_S_C_L1_2 setBeginSpacing 222.53
  $S_S_C_L1_2 setEndSpacing 426.45
$S_C_L1_2 end

set LINE_1_SPLIT_3 [pw::GridEntity getByName LINE_1-split-3]
$LINE_1_SPLIT_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L1_3 [pw::Application begin Modify [list $LINE_1_SPLIT_3]]
  set S_S_C_L1_3 [$LINE_1_SPLIT_3 getDistribution 1]
  $S_S_C_L1_3 setBeginSpacing 428.14
  $S_S_C_L1_3 setEndSpacing 644
$S_C_L1_3 end

set LINE_1_SPLIT_4 [pw::GridEntity getByName LINE_1-split-4]
$LINE_1_SPLIT_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
set S_C_L1_4 [pw::Application begin Modify [list $LINE_1_SPLIT_4]]
  set S_S_C_L1_4 [$LINE_1_SPLIT_4 getDistribution 1]
  $S_S_C_L1_4 setBeginSpacing 607.89
  $S_S_C_L1_4 setEndSpacing 628.90
$S_C_L1_4 end

set LINE_1_SPLIT_5 [pw::GridEntity getByName LINE_1-split-5]
$LINE_1_SPLIT_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L1_5 [pw::Application begin Modify [list $LINE_1_SPLIT_5]]
  set S_S_C_L1_5 [$LINE_1_SPLIT_5 getDistribution 1]
  $S_S_C_L1_5 setBeginSpacing 622.44
  $S_S_C_L1_5 setEndSpacing 632.36
$S_C_L1_5 end

set LINE_1_SPLIT_6 [pw::GridEntity getByName LINE_1-split-6]
$LINE_1_SPLIT_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L1_6 [pw::Application begin Modify [list $LINE_1_SPLIT_6]]
  set S_S_C_L1_6 [$LINE_1_SPLIT_6 getDistribution 1]
  $S_S_C_L1_6 setBeginSpacing 632.31
  $S_S_C_L1_6 setEndSpacing 796.37
$S_C_L1_6 end

set LINE_1_SPLIT_7 [pw::GridEntity getByName LINE_1-split-7]
$LINE_1_SPLIT_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L1_7 [pw::Application begin Modify [list $LINE_1_SPLIT_7]]
  set S_S_C_L1_7 [$LINE_1_SPLIT_7 getDistribution 1]
  $S_S_C_L1_7 setBeginSpacing 798.60
  $S_S_C_L1_7 setEndSpacing 875.13
$S_C_L1_7 end

set LINE_1_SPLIT_8 [pw::GridEntity getByName LINE_1-split-8]
$LINE_1_SPLIT_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L1_8 [pw::Application begin Modify [list $LINE_1_SPLIT_8]]
  set S_S_C_L1_8 [$LINE_1_SPLIT_8 getDistribution 1]
  $S_S_C_L1_8 setBeginSpacing 880.60
  $S_S_C_L1_8 setEndSpacing 1079.97
$S_C_L1_8 end

set LINE_1_SPLIT_9 [pw::GridEntity getByName LINE_1-split-9]
$LINE_1_SPLIT_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L1_9 [pw::Application begin Modify [list $LINE_1_SPLIT_9]]
  set S_S_C_L1_9 [$LINE_1_SPLIT_9 getDistribution 1]
  $S_S_C_L1_9 setBeginSpacing 1080.58
  $S_S_C_L1_9 setEndSpacing 1053.08
$S_C_L1_9 end

set LINE_1_SPLIT_10 [pw::GridEntity getByName LINE_1-split-10]
$LINE_1_SPLIT_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L1_10 [pw::Application begin Modify [list $LINE_1_SPLIT_10]]
  set S_S_C_L1_10 [$LINE_1_SPLIT_10 getDistribution 1]
  $S_S_C_L1_10 setBeginSpacing 1053
  $S_S_C_L1_10 setEndSpacing 1107
$S_C_L1_10 end

set LINE_1_SPLIT_11 [pw::GridEntity getByName LINE_1-split-11]
$LINE_1_SPLIT_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L1_11 [pw::Application begin Modify [list $LINE_1_SPLIT_11]]
  set S_S_C_L1_11 [$LINE_1_SPLIT_11 getDistribution 1]
  $S_S_C_L1_11 setBeginSpacing 1107.23
  $S_S_C_L1_11 setEndSpacing 796.89
$S_C_L1_11 end

set LINE_1_SPLIT_12 [pw::GridEntity getByName LINE_1-split-12]
$LINE_1_SPLIT_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
set S_C_L1_12 [pw::Application begin Modify [list $LINE_1_SPLIT_12]]
  set S_S_C_L1_12 [$LINE_1_SPLIT_12 getDistribution 1]
  $S_S_C_L1_12 setBeginSpacing 796.81
  $S_S_C_L1_12 setEndSpacing 427.02
$S_C_L1_12 end

set LINE_1_SPLIT_13 [pw::GridEntity getByName LINE_1-split-13]
$LINE_1_SPLIT_13 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
set S_C_L1_13 [pw::Application begin Modify [list $LINE_1_SPLIT_13]]
  set S_S_C_L1_13 [$LINE_1_SPLIT_13 getDistribution 1]
  $S_S_C_L1_13 setBeginSpacing 427.72
  $S_S_C_L1_13 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L1_13 end

# SPLIT LINE_2
# S_L_2 = SPLIT LINE 2
# S_C_L2 = SPACING CONSTRATIN LINE2 
# S_S_C_L2_2 = SELECT SPACING CONSTRATIN LINE2 

set S_L_2_1 [list]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 95378"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 94157"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 90618"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 83928"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 79546"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 75402"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 70427"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 64712"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 38209"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 11427"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 5044"]]
lappend S_L_2_1 [$C_L_2 getParameter -Z -[expr "-$z2 - 2222"]]
set L_S_2_1 [$C_L_2 split $S_L_2_1]
 
set LINE_2_SPLIT_1 [pw::GridEntity getByName LINE_2-split-1]
$LINE_2_SPLIT_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
set S_C_L2_1 [pw::Application begin Modify [list $LINE_2_SPLIT_1]]
  set S_S_C_L2_1 [$LINE_2_SPLIT_1 getDistribution 1]
  $S_S_C_L2_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_L2_1 setEndSpacing 222.75
$S_C_L2_1 end

set LINE_2_SPLIT_2 [pw::GridEntity getByName LINE_2-split-2]
$LINE_2_SPLIT_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
set S_C_L2_2 [pw::Application begin Modify [list $LINE_2_SPLIT_2]]
  set S_S_C_L2_2 [$LINE_2_SPLIT_2 getDistribution 1]
  $S_S_C_L2_2 setBeginSpacing 222.53
  $S_S_C_L2_2 setEndSpacing 426.45
$S_C_L2_2 end

set LINE_2_SPLIT_3 [pw::GridEntity getByName LINE_2-split-3]
$LINE_2_SPLIT_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L2_3 [pw::Application begin Modify [list $LINE_2_SPLIT_3]]
  set S_S_C_L2_3 [$LINE_2_SPLIT_3 getDistribution 1]
  $S_S_C_L2_3 setBeginSpacing 428.14
  $S_S_C_L2_3 setEndSpacing 644
$S_C_L2_3 end

set LINE_2_SPLIT_4 [pw::GridEntity getByName LINE_2-split-4]
$LINE_2_SPLIT_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
set S_C_L2_4 [pw::Application begin Modify [list $LINE_2_SPLIT_4]]
  set S_S_C_L2_4 [$LINE_2_SPLIT_4 getDistribution 1]
  $S_S_C_L2_4 setBeginSpacing 607.89
  $S_S_C_L2_4 setEndSpacing 628.90
$S_C_L2_4 end

set LINE_2_SPLIT_5 [pw::GridEntity getByName LINE_2-split-5]
$LINE_2_SPLIT_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L2_5 [pw::Application begin Modify [list $LINE_2_SPLIT_5]]
  set S_S_C_L2_5 [$LINE_2_SPLIT_5 getDistribution 1]
  $S_S_C_L2_5 setBeginSpacing 622.44
  $S_S_C_L2_5 setEndSpacing 632.36
$S_C_L2_5 end

set LINE_2_SPLIT_6 [pw::GridEntity getByName LINE_2-split-6]
$LINE_2_SPLIT_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L2_6 [pw::Application begin Modify [list $LINE_2_SPLIT_6]]
  set S_S_C_L2_6 [$LINE_2_SPLIT_6 getDistribution 1]
  $S_S_C_L2_6 setBeginSpacing 632.31
  $S_S_C_L2_6 setEndSpacing 796.37
$S_C_L2_6 end

set LINE_2_SPLIT_7 [pw::GridEntity getByName LINE_2-split-7]
$LINE_2_SPLIT_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L2_7 [pw::Application begin Modify [list $LINE_2_SPLIT_7]]
  set S_S_C_L2_7 [$LINE_2_SPLIT_7 getDistribution 1]
  $S_S_C_L2_7 setBeginSpacing 798.60
  $S_S_C_L2_7 setEndSpacing 875.13
$S_C_L2_7 end

set LINE_2_SPLIT_8 [pw::GridEntity getByName LINE_2-split-8]
$LINE_2_SPLIT_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L2_8 [pw::Application begin Modify [list $LINE_2_SPLIT_8]]
  set S_S_C_L2_8 [$LINE_2_SPLIT_8 getDistribution 1]
  $S_S_C_L2_8 setBeginSpacing 880.60
  $S_S_C_L2_8 setEndSpacing 1079.97
$S_C_L2_8 end

set LINE_2_SPLIT_9 [pw::GridEntity getByName LINE_2-split-9]
$LINE_2_SPLIT_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L2_9 [pw::Application begin Modify [list $LINE_2_SPLIT_9]]
  set S_S_C_L2_9 [$LINE_2_SPLIT_9 getDistribution 1]
  $S_S_C_L2_9 setBeginSpacing 1080.58
  $S_S_C_L2_9 setEndSpacing 1053.08
$S_C_L2_9 end

set LINE_2_SPLIT_10 [pw::GridEntity getByName LINE_2-split-10]
$LINE_2_SPLIT_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L2_10 [pw::Application begin Modify [list $LINE_2_SPLIT_10]]
  set S_S_C_L2_10 [$LINE_2_SPLIT_10 getDistribution 1]
  $S_S_C_L2_10 setBeginSpacing 1053
  $S_S_C_L2_10 setEndSpacing 1107
$S_C_L2_10 end

set LINE_2_SPLIT_11 [pw::GridEntity getByName LINE_2-split-11]
$LINE_2_SPLIT_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L2_11 [pw::Application begin Modify [list $LINE_2_SPLIT_11]]
  set S_S_C_L2_11 [$LINE_2_SPLIT_11 getDistribution 1]
  $S_S_C_L2_11 setBeginSpacing 1107.23
  $S_S_C_L2_11 setEndSpacing 796.89
$S_C_L2_11 end

set LINE_2_SPLIT_12 [pw::GridEntity getByName LINE_2-split-12]
$LINE_2_SPLIT_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
set S_C_L2_12 [pw::Application begin Modify [list $LINE_2_SPLIT_12]]
  set S_S_C_L2_12 [$LINE_2_SPLIT_12 getDistribution 1]
  $S_S_C_L2_12 setBeginSpacing 796.81
  $S_S_C_L2_12 setEndSpacing 427.02
$S_C_L2_12 end

set LINE_2_SPLIT_13 [pw::GridEntity getByName LINE_2-split-13]
$LINE_2_SPLIT_13 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
set S_C_L2_13 [pw::Application begin Modify [list $LINE_2_SPLIT_13]]
  set S_S_C_L2_13 [$LINE_2_SPLIT_13 getDistribution 1]
  $S_S_C_L2_13 setBeginSpacing 427.72
  $S_S_C_L2_13 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L2_13 end

# SPLIT LINE_3
# S_L_3 = SPLIT LINE 3
# S_C_L3 = SPACING CONSTRATIN LINE3 
# S_S_C_L3_2 = SELECT SPACING CONSTRATIN LINE3 

set S_L_3_1 [list]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 95378"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 94157"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 90618"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 83928"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 79546"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 75402"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 70427"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 64712"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 38209"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 11427"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 5044"]]
lappend S_L_3_1 [$C_L_3 getParameter -Z -[expr "-$z2 - 2222"]]
set L_S_3_1 [$C_L_3 split $S_L_3_1]

set LINE_3_SPLIT_1 [pw::GridEntity getByName LINE_3-split-1]
$LINE_3_SPLIT_1 setDimension [expr "$NUMBER_OF_CONNECTORS"]
set S_C_L3_1 [pw::Application begin Modify [list $LINE_3_SPLIT_1]]
  set S_S_C_L3_1 [$LINE_3_SPLIT_1 getDistribution 1]
  $S_S_C_L3_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_L3_1 setEndSpacing 222.75
$S_C_L3_1 end

set LINE_3_SPLIT_2 [pw::GridEntity getByName LINE_3-split-2]
$LINE_3_SPLIT_2 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 3"]
set S_C_L3_2 [pw::Application begin Modify [list $LINE_3_SPLIT_2]]
  set S_S_C_L3_2 [$LINE_3_SPLIT_2 getDistribution 1]
  $S_S_C_L3_2 setBeginSpacing 222.53
  $S_S_C_L3_2 setEndSpacing 426.45
$S_C_L3_2 end

set LINE_3_SPLIT_3 [pw::GridEntity getByName LINE_3-split-3]
$LINE_3_SPLIT_3 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L3_3 [pw::Application begin Modify [list $LINE_3_SPLIT_3]]
  set S_S_C_L3_3 [$LINE_3_SPLIT_3 getDistribution 1]
  $S_S_C_L3_3 setBeginSpacing 428.14
  $S_S_C_L3_3 setEndSpacing 644
$S_C_L3_3 end

set LINE_3_SPLIT_4 [pw::GridEntity getByName LINE_3-split-4]
$LINE_3_SPLIT_4 setDimension [expr "$NUMBER_OF_CONNECTORS/4"]
set S_C_L3_4 [pw::Application begin Modify [list $LINE_3_SPLIT_4]]
  set S_S_C_L3_4 [$LINE_3_SPLIT_4 getDistribution 1]
  $S_S_C_L3_4 setBeginSpacing 607.89
  $S_S_C_L3_4 setEndSpacing 628.90
$S_C_L3_4 end

set LINE_3_SPLIT_5 [pw::GridEntity getByName LINE_3-split-5]
$LINE_3_SPLIT_5 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L3_5 [pw::Application begin Modify [list $LINE_3_SPLIT_5]]
  set S_S_C_L3_5 [$LINE_3_SPLIT_5 getDistribution 1]
  $S_S_C_L3_5 setBeginSpacing 622.44
  $S_S_C_L3_5 setEndSpacing 632.36
$S_C_L3_5 end

set LINE_3_SPLIT_6 [pw::GridEntity getByName LINE_3-split-6]
$LINE_3_SPLIT_6 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L3_6 [pw::Application begin Modify [list $LINE_3_SPLIT_6]]
  set S_S_C_L3_6 [$LINE_3_SPLIT_6 getDistribution 1]
  $S_S_C_L3_6 setBeginSpacing 632.31
  $S_S_C_L3_6 setEndSpacing 796.37
$S_C_L3_6 end

set LINE_3_SPLIT_7 [pw::GridEntity getByName LINE_3-split-7]
$LINE_3_SPLIT_7 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L3_7 [pw::Application begin Modify [list $LINE_3_SPLIT_7]]
  set S_S_C_L3_7 [$LINE_3_SPLIT_7 getDistribution 1]
  $S_S_C_L3_7 setBeginSpacing 798.60
  $S_S_C_L3_7 setEndSpacing 875.13
$S_C_L3_7 end

set LINE_3_SPLIT_8 [pw::GridEntity getByName LINE_3-split-8]
$LINE_3_SPLIT_8 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 1"]
set S_C_L3_8 [pw::Application begin Modify [list $LINE_3_SPLIT_8]]
  set S_S_C_L3_8 [$LINE_3_SPLIT_8 getDistribution 1]
  $S_S_C_L3_8 setBeginSpacing 880.60
  $S_S_C_L3_8 setEndSpacing 1079.97
$S_C_L3_8 end

set LINE_3_SPLIT_9 [pw::GridEntity getByName LINE_3-split-9]
$LINE_3_SPLIT_9 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L3_9 [pw::Application begin Modify [list $LINE_3_SPLIT_9]]
  set S_S_C_L3_9 [$LINE_3_SPLIT_9 getDistribution 1]
  $S_S_C_L3_9 setBeginSpacing 1080.58
  $S_S_C_L3_9 setEndSpacing 1053.08
$S_C_L3_9 end

set LINE_3_SPLIT_10 [pw::GridEntity getByName LINE_3-split-10]
$LINE_3_SPLIT_10 setDimension [expr "$NUMBER_OF_CONNECTORS/2 + 2"]
set S_C_L3_10 [pw::Application begin Modify [list $LINE_3_SPLIT_10]]
  set S_S_C_L3_10 [$LINE_3_SPLIT_10 getDistribution 1]
  $S_S_C_L3_10 setBeginSpacing 1053
  $S_S_C_L3_10 setEndSpacing 1107
$S_C_L3_10 end

set LINE_3_SPLIT_11 [pw::GridEntity getByName LINE_3-split-11]
$LINE_3_SPLIT_11 setDimension [expr "$NUMBER_OF_CONNECTORS/6"]
set S_C_L3_11 [pw::Application begin Modify [list $LINE_3_SPLIT_11]]
  set S_S_C_L3_11 [$LINE_3_SPLIT_11 getDistribution 1]
  $S_S_C_L3_11 setBeginSpacing 1107.23
  $S_S_C_L3_11 setEndSpacing 796.89
$S_C_L3_11 end

set LINE_3_SPLIT_12 [pw::GridEntity getByName LINE_3-split-12]
$LINE_3_SPLIT_12 setDimension [expr "$NUMBER_OF_CONNECTORS/6 - 2"]
set S_C_L3_12 [pw::Application begin Modify [list $LINE_3_SPLIT_12]]
  set S_S_C_L3_12 [$LINE_3_SPLIT_12 getDistribution 1]
  $S_S_C_L3_12 setBeginSpacing 796.81
  $S_S_C_L3_12 setEndSpacing 427.02
$S_C_L3_12 end

set LINE_3_SPLIT_13 [pw::GridEntity getByName LINE_3-split-13]
$LINE_3_SPLIT_13 setDimension [expr "$NUMBER_OF_CONNECTORS + 2"]
set S_C_L3_13 [pw::Application begin Modify [list $LINE_3_SPLIT_13]]
  set S_S_C_L3_13 [$LINE_3_SPLIT_13 getDistribution 1]
  $S_S_C_L3_13 setBeginSpacing 427.72
  $S_S_C_L3_13 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L3_13 end

# ----------------------------------------------------------------------------------------------
# CREATE LINE BETWEEN ROOT AIRFOIL AND ROOTSIDE CIRCLE
# ----------------------------------------------------------------------------------------------

set C_L_B_RA_A_RC [pw::Application begin Create]

set RA_P_1 [pw::SegmentSpline create]
set RA_P_2 [pw::SegmentSpline create]
set RA_P_3 [pw::SegmentSpline create]
$RA_P_1 addPoint "[expr $CYLINDER_RADIUS - 2844.1234 + $x1] [expr $CYLINDER_RADIUS - 4368.81996 + $y1] $z1"
$RA_P_2 addPoint "[expr $CYLINDER_RADIUS - 2842.3881 + $x1] [expr $CYLINDER_RADIUS - 4374.76388 + $y1] $z1"
$RA_P_3 addPoint "-[expr $CYLINDER_RADIUS - 2839.1226 + $x1] -[expr $CYLINDER_RADIUS - 4371.19702 + $y1] [expr $z1 + 0.0017]"

set C_L_B_RA_A_RC_1 [pw::SegmentSpline create]
set C_L_B_RA_A_RC_2 [pw::SegmentSpline create]
set C_L_B_RA_A_RC_3 [pw::SegmentSpline create]

$C_L_B_RA_A_RC_1 addPoint [$FOURTH_POINT getPosition -arc 0]
$C_L_B_RA_A_RC_1 addPoint [$RA_P_1 getPosition -arc 0]

$C_L_B_RA_A_RC_2 addPoint [$THIRD_POINT getPosition -arc 0]
$C_L_B_RA_A_RC_2 addPoint [$RA_P_2 getPosition -arc 0]

$C_L_B_RA_A_RC_3 addPoint [$SECOUND_POINT getPosition -arc 0]
$C_L_B_RA_A_RC_3 addPoint [$RA_P_3 getPosition -arc 0]

set CL1 [pw::Connector create]
$CL1 addSegment $C_L_B_RA_A_RC_1

set CL2 [pw::Connector create]
$CL2 addSegment $C_L_B_RA_A_RC_2

set CL3 [pw::Connector create]
$CL3 addSegment $C_L_B_RA_A_RC_3

$CL1 setName RA_RC_1; $CL2 setName RA_RC_2; $CL3 setName RA_RC_3

$CL1 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $CL2 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $CL3 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]

$C_L_B_RA_A_RC end

set S_C_RA_RC_1 [pw::Application begin Modify [list $CL1]]
  set S_S_C_RA_RC_1 [$CL1 getDistribution 1]
  $S_S_C_RA_RC_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_RA_RC_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_RA_RC_1 end

set S_C_RA_RC_2 [pw::Application begin Modify [list $CL2]]
  set S_S_C_RA_RC_2 [$CL2 getDistribution 1]
  $S_S_C_RA_RC_2 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_RA_RC_2 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_RA_RC_2 end

set S_C_RA_RC_3 [pw::Application begin Modify [list $CL3]]
  set S_S_C_RA_RC_3 [$CL3 getDistribution 1]
  $S_S_C_RA_RC_3 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_RA_RC_3 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_RA_RC_3 end

# ----------------------------------------------------------------------------------------------
# CREATE LINE BETWEEN TIP AIRFOIL AND TIPSIDE CIRCLE
# ----------------------------------------------------------------------------------------------

set C_L_B_TA_A_TC [pw::Application begin Create]

set TA_P_1 [pw::SegmentSpline create]
set TA_P_2 [pw::SegmentSpline create]
set TA_P_3 [pw::SegmentSpline create]
$TA_P_1 addPoint "[expr $CYLINDER_RADIUS - 4934.989776 + $x1] [expr $CYLINDER_RADIUS - 4998.3655066 + $y1] $z2"
$TA_P_2 addPoint "[expr $CYLINDER_RADIUS - 4935.012279 + $x1] -[expr $CYLINDER_RADIUS - 4997.6345534 + $y1] $z2"
$TA_P_3 addPoint "-[expr $CYLINDER_RADIUS - 4965.064696 + $x1] [expr $CYLINDER_RADIUS - 4999.1676887 + $y1] $z2"

set C_L_B_TA_A_TC_1 [pw::SegmentSpline create]
set C_L_B_TA_A_TC_2 [pw::SegmentSpline create]
set C_L_B_TA_A_TC_3 [pw::SegmentSpline create]

$C_L_B_TA_A_TC_1 addPoint [$FOURTH_POINT_TS getPosition -arc 0]
$C_L_B_TA_A_TC_1 addPoint [$TA_P_1 getPosition -arc 0]

$C_L_B_TA_A_TC_2 addPoint [$THIRD_POINT_TS getPosition -arc 0]
$C_L_B_TA_A_TC_2 addPoint [$TA_P_2 getPosition -arc 0]

$C_L_B_TA_A_TC_3 addPoint [$SECOUND_POINT_TS getPosition -arc 0]
$C_L_B_TA_A_TC_3 addPoint [$TA_P_3 getPosition -arc 0]

set CL4 [pw::Connector create]
$CL4 addSegment $C_L_B_TA_A_TC_1

set CL5 [pw::Connector create]
$CL5 addSegment $C_L_B_TA_A_TC_2

set CL6 [pw::Connector create]
$CL6 addSegment $C_L_B_TA_A_TC_3

$CL4 setName TA_TC_1; $CL5 setName TA_TC_2; $CL6 setName TA_TC_3

$CL4 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $CL5 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $CL6 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]

$C_L_B_TA_A_TC end

set S_C_TA_TC_1 [pw::Application begin Modify [list $CL4]]
  set S_S_C_TA_TC_1 [$CL4 getDistribution 1]
  $S_S_C_TA_TC_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_TA_TC_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_TA_TC_1 end

set S_C_TA_TC_2 [pw::Application begin Modify [list $CL5]]
  set S_S_C_TA_TC_2 [$CL5 getDistribution 1]
  $S_S_C_TA_TC_2 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_TA_TC_2 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_TA_TC_2 end

set S_C_TA_TC_3 [pw::Application begin Modify [list $CL6]]
  set S_S_C_TA_TC_3 [$CL6 getDistribution 1]
  $S_S_C_TA_TC_3 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_S_C_TA_TC_3 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_TA_TC_3 end

# ----------------------------------------------------------------------------------------------
# CREATE A LINE BETWEEN TRAILING EDGE INLET PRESSURE AIRFOIL
# ----------------------------------------------------------------------------------------------

set CREATE_A_LINE_BETWEEN_TRAILING_EDGE_INLET_PRESSURE_AIRFOIL [pw::Application begin Create]
# This action creates a new connector spline segment object
set seg701 [pw::SegmentSpline create];  set seg702 [pw::SegmentSpline create];  set seg703 [pw::SegmentSpline create]; 
set seg704 [pw::SegmentSpline create];  set seg705 [pw::SegmentSpline create];  set seg706 [pw::SegmentSpline create];
set seg707 [pw::SegmentSpline create];  set seg708 [pw::SegmentSpline create];  set seg709 [pw::SegmentSpline create];
set seg710 [pw::SegmentSpline create];  set seg711 [pw::SegmentSpline create];  set seg712 [pw::SegmentSpline create];
# it is represented of co-ordinate value of axises
$seg701 addPoint "2168.9867 623.49517 -4622";            $seg702 addPoint "2198.2274 617.70142 -5843"
$seg701 addPoint "3686.2943 -3378.0519 -4622";            $seg702 addPoint "3686.2943 -3378.0519 -5843"

$seg703 addPoint "2426.4477 543.53544 -9382";        $seg704 addPoint "3205.0269 191.08042 -16072"
$seg703 addPoint "3686.2943 -3378.0519 -9382";        $seg704 addPoint "3686.2943 -3378.0519 -16072"

$seg705 addPoint "3701.2259 61.456528 -20454";        $seg706 addPoint "3964.5219 401.17962 -24598"
$seg705 addPoint "3686.2943 -3378.0519 -20454";        $seg706 addPoint "3686.2943 -3378.0519 -24598"

$seg707 addPoint "4061.3778 537.09573 -29573";        $seg708 addPoint "3639.2452 341.82789 -35288";       
$seg707 addPoint "3686.2943 -3378.0519 -29573";       $seg708 addPoint "3686.2943 -3378.0519 -35288";

$seg709 addPoint "1987.9217 27.333952 -61791";        $seg710 addPoint "1489.3021 4.0965721 -88573";       
$seg709 addPoint "3686.2943 -3378.0519 -61791";       $seg710 addPoint "3686.2943 -3378.0519 -88573";

$seg711 addPoint "1202.2444 -3.7460339 -94956";        $seg712 addPoint "812.01877 -5.4241668 -97778";       
$seg711 addPoint "3686.2943 -3378.0519 -94956";       $seg712 addPoint "3686.2943 -3378.0519 -97778";

# It creates a new connector object
set RA_RC_2_1 [pw::Connector create];  set RA_RC_2_2 [pw::Connector create];  set RA_RC_2_3 [pw::Connector create]
set RA_RC_2_4 [pw::Connector create]; set RA_RC_2_5 [pw::Connector create]; set RA_RC_2_6 [pw::Connector create]; 
set RA_RC_2_7 [pw::Connector create]; set RA_RC_2_8 [pw::Connector create]; set RA_RC_2_9 [pw::Connector create];
set RA_RC_2_10 [pw::Connector create]; set RA_RC_2_11 [pw::Connector create]; set RA_RC_2_12 [pw::Connector create]
# seg variable add in line variable
$RA_RC_2_1 addSegment $seg701;    $RA_RC_2_2 addSegment $seg702;   $RA_RC_2_3 addSegment $seg703;  
$RA_RC_2_4 addSegment $seg704;    $RA_RC_2_5 addSegment $seg705;   $RA_RC_2_6 addSegment $seg706;  
$RA_RC_2_7 addSegment $seg707;    $RA_RC_2_8 addSegment $seg708;   $RA_RC_2_9 addSegment $seg709;    
$RA_RC_2_10 addSegment $seg710;   $RA_RC_2_11 addSegment $seg711;  $RA_RC_2_12 addSegment $seg712;
# It's creating line 113 points
$RA_RC_2_1 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_2 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_3 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_2_4 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_5 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_6 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_2_7 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_8 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_9 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];
$RA_RC_2_10 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_11 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_2_12 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];

$RA_RC_2_1 setName RA_RC_2_1; $RA_RC_2_2 setName RA_RC_2_2; $RA_RC_2_3 setName RA_RC_2_3; $RA_RC_2_4 setName RA_RC_2_4;
$RA_RC_2_5 setName RA_RC_2_5; $RA_RC_2_6 setName RA_RC_2_6; $RA_RC_2_7 setName RA_RC_2_7; $RA_RC_2_8 setName RA_RC_2_8;
$RA_RC_2_9 setName RA_RC_2_9; $RA_RC_2_10 setName RA_RC_2_10; $RA_RC_2_11 setName RA_RC_2_11; $RA_RC_2_12 setName RA_RC_2_12;

$CREATE_A_LINE_BETWEEN_TRAILING_EDGE_INLET_PRESSURE_AIRFOIL end

set S_C_L_B_RA_LA_2_1 [pw::Application begin Modify [list $RA_RC_2_1]]
  set S_L_2_1 [$RA_RC_2_1 getDistribution 1]
  $S_L_2_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_2_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_1 end

set S_C_L_B_RA_LA_2_2 [pw::Application begin Modify [list $RA_RC_2_2]]
  set S_L_2_2 [$RA_RC_2_2 getDistribution 1]
  $S_L_2_2 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_2_2 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_2 end

set S_C_L_B_RA_LA_2_3 [pw::Application begin Modify [list $RA_RC_2_3]]
  set S_L_2_3 [$RA_RC_2_3 getDistribution 1]
  $S_L_2_3 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_2_3 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_3 end

set S_C_L_B_RA_LA_2_4 [pw::Application begin Modify [list $RA_RC_2_4]]
  set S_L_2_4 [$RA_RC_2_4 getDistribution 1]
  $S_L_2_4 setBeginSpacing 0.1
  $S_L_2_4 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_4 end

set S_C_L_B_RA_LA_2_5 [pw::Application begin Modify [list $RA_RC_2_5]]
  set S_L_2_5 [$RA_RC_2_5 getDistribution 1]
  $S_L_2_5 setBeginSpacing 0.2
  $S_L_2_5 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_5 end

set S_C_L_B_RA_LA_2_6 [pw::Application begin Modify [list $RA_RC_2_6]]
  set S_L_2_6 [$RA_RC_2_6 getDistribution 1]
  $S_L_2_6 setBeginSpacing 0.25
  $S_L_2_6 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_6 end

set S_C_L_B_RA_LA_2_7 [pw::Application begin Modify [list $RA_RC_2_7]]
  set S_L_2_7 [$RA_RC_2_7 getDistribution 1]
  $S_L_2_7 setBeginSpacing 0.6
  $S_L_2_7 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_7 end

set S_C_L_B_RA_LA_2_8 [pw::Application begin Modify [list $RA_RC_2_8]]
  set S_L_2_8 [$RA_RC_2_8 getDistribution 1]
  $S_L_2_8 setBeginSpacing 0.6
  $S_L_2_8 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_8 end

set S_C_L_B_RA_LA_2_9 [pw::Application begin Modify [list $RA_RC_2_9]]
  set S_L_2_9 [$RA_RC_2_9 getDistribution 1]
  $S_L_2_9 setBeginSpacing 0.45
  $S_L_2_9 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_9 end

set S_C_L_B_RA_LA_2_10 [pw::Application begin Modify [list $RA_RC_2_10]]
  set S_L_2_10 [$RA_RC_2_10 getDistribution 1]
  $S_L_2_10 setBeginSpacing 0.4
  $S_L_2_10 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_10 end

set S_C_L_B_RA_LA_2_11 [pw::Application begin Modify [list $RA_RC_2_11]]
  set S_L_2_11 [$RA_RC_2_11 getDistribution 1]
  $S_L_2_11 setBeginSpacing 0.45
  $S_L_2_11 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_11 end

set S_C_L_B_RA_LA_2_12 [pw::Application begin Modify [list $RA_RC_2_12]]
  set S_L_2_12 [$RA_RC_2_12 getDistribution 1]
  $S_L_2_12 setBeginSpacing 0.45
  $S_L_2_12 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_2_12 end

# ----------------------------------------------------------------------------------------------
# CREATE A LINE BETWEEN TRAILING EDGE outlet PRESSURE AIRFOIL
# ----------------------------------------------------------------------------------------------

set CREATE_A_LINE_BETWEEN_TRAILING_EDGE_OUTLET_PRESSURE_AIRFOIL [pw::Application begin Create]
# This action creates a new connector spline segment object
set seg801 [pw::SegmentSpline create];  set seg802 [pw::SegmentSpline create];  set seg803 [pw::SegmentSpline create]; 
set seg804 [pw::SegmentSpline create];  set seg805 [pw::SegmentSpline create];  set seg806 [pw::SegmentSpline create];
set seg807 [pw::SegmentSpline create];  set seg808 [pw::SegmentSpline create];  set seg809 [pw::SegmentSpline create];
set seg810 [pw::SegmentSpline create];  set seg811 [pw::SegmentSpline create];  set seg812 [pw::SegmentSpline create];
# it is represented of co-ordinate value of axises
$seg801 addPoint "2164.3891 639.30328 -4622";            $seg802 addPoint "2185.2769 662.16797 -5843"
$seg801 addPoint "4794.1375 1419.9456 -4622";           $seg802 addPoint "4794.1375 1419.9456 -5843"

$seg803 addPoint "2335.5179 858.20442 -9382";        $seg804 addPoint "2885.0032 1454.5971 -16072"
$seg803 addPoint "4794.1375 1419.9456 -9382";       $seg804 addPoint "4794.1375 1419.9456 -16072"

$seg805 addPoint "3364.1835 1604.2 -20454";        $seg806 addPoint "3840.2607 1079.4821 -24598"
$seg805 addPoint "4794.1375 1419.9456 -20454";       $seg806 addPoint "4794.1375 1419.9456 -24598"

$seg807 addPoint "4049.1237 624.13525 -29573";        $seg808 addPoint "3631.9207 412.14572 -35288";       
$seg807 addPoint "4794.1375 1419.9456 -29573";       $seg808 addPoint "4794.1375 1419.9456 -35288";

$seg809 addPoint "1986.9913 66.567066 -61791";        $seg810 addPoint "1489.2267 15.632213 -88573";       
$seg809 addPoint "4794.1375 1419.9456 -61791";       $seg810 addPoint "4794.1375 1419.9456 -88573";

$seg811 addPoint "1202.2355 5.0376815 -94956";       $seg812 addPoint "812.03425 0.95623331 -97778";       
$seg811 addPoint "4794.1375 1419.9456 -94956";       $seg812 addPoint "4794.1375 1419.9456 -97778";

# It creates a new connector object
set RA_RC_1_1 [pw::Connector create];  set RA_RC_1_2 [pw::Connector create];  set RA_RC_1_3 [pw::Connector create]
set RA_RC_1_4 [pw::Connector create]; set RA_RC_1_5 [pw::Connector create]; set RA_RC_1_6 [pw::Connector create]; 
set RA_RC_1_7 [pw::Connector create]; set RA_RC_1_8 [pw::Connector create]; set RA_RC_1_9 [pw::Connector create];
set RA_RC_1_10 [pw::Connector create]; set RA_RC_1_11 [pw::Connector create]; set RA_RC_1_12 [pw::Connector create]
# seg variable add in line variable
$RA_RC_1_1 addSegment $seg801;    $RA_RC_1_2 addSegment $seg802;   $RA_RC_1_3 addSegment $seg803;  
$RA_RC_1_4 addSegment $seg804;    $RA_RC_1_5 addSegment $seg805;   $RA_RC_1_6 addSegment $seg806;  
$RA_RC_1_7 addSegment $seg807;    $RA_RC_1_8 addSegment $seg808;   $RA_RC_1_9 addSegment $seg809;    
$RA_RC_1_10 addSegment $seg810;   $RA_RC_1_11 addSegment $seg811;  $RA_RC_1_12 addSegment $seg812;
# It's creating line 113 points
$RA_RC_1_1 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_2 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_3 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_1_4 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_5 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_6 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_1_7 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_8 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_9 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];
$RA_RC_1_10 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_11 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_1_12 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];

$RA_RC_1_1 setName RA_RC_1_1; $RA_RC_1_2 setName RA_RC_1_2; $RA_RC_1_3 setName RA_RC_1_3; $RA_RC_1_4 setName RA_RC_1_4;
$RA_RC_1_5 setName RA_RC_1_5; $RA_RC_1_6 setName RA_RC_1_6; $RA_RC_1_7 setName RA_RC_1_7; $RA_RC_1_8 setName RA_RC_1_8;
$RA_RC_1_9 setName RA_RC_1_9; $RA_RC_1_10 setName RA_RC_1_10; $RA_RC_1_11 setName RA_RC_1_11; $RA_RC_1_12 setName RA_RC_1_12;

$CREATE_A_LINE_BETWEEN_TRAILING_EDGE_OUTLET_PRESSURE_AIRFOIL end

set S_C_L_B_RA_LA_1_1 [pw::Application begin Modify [list $RA_RC_1_1]]
  set S_L_1_1 [$RA_RC_1_1 getDistribution 1]
  $S_L_1_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_1_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_1 end

set S_C_L_B_RA_LA_1_2 [pw::Application begin Modify [list $RA_RC_1_2]]
  set S_L_1_2 [$RA_RC_1_2 getDistribution 1]
  $S_L_1_2 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_1_2 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_2 end

set S_C_L_B_RA_LA_1_3 [pw::Application begin Modify [list $RA_RC_1_3]]
  set S_L_1_3 [$RA_RC_1_3 getDistribution 1]
  $S_L_1_3 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_1_3 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_3 end

set S_C_L_B_RA_LA_1_4 [pw::Application begin Modify [list $RA_RC_1_4]]
  set S_L_1_4 [$RA_RC_1_4 getDistribution 1]
  $S_L_1_4 setBeginSpacing 0.08
  $S_L_1_4 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_4 end

set S_C_L_B_RA_LA_1_5 [pw::Application begin Modify [list $RA_RC_1_5]]
  set S_L_1_5 [$RA_RC_1_5 getDistribution 1]
  $S_L_1_5 setBeginSpacing 0.31
  $S_L_1_5 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_5 end

set S_C_L_B_RA_LA_1_6 [pw::Application begin Modify [list $RA_RC_1_6]]
  set S_L_1_6 [$RA_RC_1_6 getDistribution 1]
  $S_L_1_6 setBeginSpacing 0.41
  $S_L_1_6 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_6 end

set S_C_L_B_RA_LA_1_7 [pw::Application begin Modify [list $RA_RC_1_7]]
  set S_L_1_7 [$RA_RC_1_7 getDistribution 1]
  $S_L_1_7 setBeginSpacing 0.9
  $S_L_1_7 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_7 end

set S_C_L_B_RA_LA_1_8 [pw::Application begin Modify [list $RA_RC_1_8]]
  set S_L_1_8 [$RA_RC_1_8 getDistribution 1]
  $S_L_1_8 setBeginSpacing 0.5
  $S_L_1_8 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_8 end

set S_C_L_B_RA_LA_1_9 [pw::Application begin Modify [list $RA_RC_1_9]]
  set S_L_1_9 [$RA_RC_1_9 getDistribution 1]
  $S_L_1_9 setBeginSpacing 0.5
  $S_L_1_9 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_9 end

set S_C_L_B_RA_LA_1_10 [pw::Application begin Modify [list $RA_RC_1_10]]
  set S_L_1_10 [$RA_RC_1_10 getDistribution 1]
  $S_L_1_10 setBeginSpacing 0.5
  $S_L_1_10 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_10 end

set S_C_L_B_RA_LA_1_11 [pw::Application begin Modify [list $RA_RC_1_11]]
  set S_L_1_11 [$RA_RC_1_11 getDistribution 1]
  $S_L_1_11 setBeginSpacing 0.51
  $S_L_1_11 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_11 end

set S_C_L_B_RA_LA_1_12 [pw::Application begin Modify [list $RA_RC_1_12]]
  set S_L_1_12 [$RA_RC_1_12 getDistribution 1]
  $S_L_1_12 setBeginSpacing 0.6
  $S_L_1_12 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_1_12 end

# ----------------------------------------------------------------------------------------------
# CREATE A LINE BETWEEN LEADING EDGE AIRFOIL AND LEADING EDGE CYLINDER
# ----------------------------------------------------------------------------------------------

set CREATE_A_LINE_BETWEEN_LEADING_EDGE_AIRFOIL_AND_LEADING_EDGE_CYLINDER [pw::Application begin Create]
# This action creates a new connector spline segment object
set seg901 [pw::SegmentSpline create];  set seg902 [pw::SegmentSpline create];  set seg903 [pw::SegmentSpline create]; 
set seg904 [pw::SegmentSpline create];  set seg905 [pw::SegmentSpline create];  set seg906 [pw::SegmentSpline create];
set seg907 [pw::SegmentSpline create];  set seg908 [pw::SegmentSpline create];  set seg909 [pw::SegmentSpline create];
set seg910 [pw::SegmentSpline create];  set seg911 [pw::SegmentSpline create];  set seg912 [pw::SegmentSpline create];
# it is represented of co-ordinate value of axises
$seg901 addPoint "-2133.3172 -620.64052 -4622";            $seg902 addPoint "-2106.4543 -612.68462 -5843"
$seg901 addPoint "-4818.1888 -1336.0601 -4622";           $seg902 addPoint "-4818.1888 -1336.0601 -5843"

$seg903 addPoint "-2028.5939 -589.62487 -9382";        $seg904 addPoint "-1881.4093 -546.03354 -16072"
$seg903 addPoint "-4818.1888 -1336.0601 -9382";       $seg904 addPoint "-4818.1888 -1336.0601 -16072"

$seg905 addPoint "-1785.0022 -517.4809 -20454";        $seg906 addPoint "-1693.8314 -490.47903 -24598"
$seg905 addPoint "-4818.1888 -1336.0601 -20454";       $seg906 addPoint "-4818.1888 -1336.0601 -24598"

$seg907 addPoint "-1584.3779 -458.06246 -29573";        $seg908 addPoint "-1458.644 -420.82413 -35288";       
$seg907 addPoint "-4818.1888 -1336.0601 -29573";       $seg908 addPoint "-4818.1888 -1336.0601 -35288";

$seg909 addPoint "-875.55969 -248.1334 -61791";        $seg910 addPoint "-286.33719 -73.624736 -88573";       
$seg909 addPoint "-4818.1888 -1336.0601 -61791";       $seg910 addPoint "-4818.1888 -1336.0601 -88573";

$seg911 addPoint "-145.90679 -32.033786 -94956";       $seg912 addPoint "-83.820838 -13.645935 -97778";       
$seg911 addPoint "-4818.1888 -1336.0601 -94956";       $seg912 addPoint "-4818.1888 -1336.0601 -97778";

# It creates a new connector object
set RA_RC_3_1 [pw::Connector create];  set RA_RC_3_2 [pw::Connector create];  set RA_RC_3_3 [pw::Connector create]
set RA_RC_3_4 [pw::Connector create]; set RA_RC_3_5 [pw::Connector create]; set RA_RC_3_6 [pw::Connector create]; 
set RA_RC_3_7 [pw::Connector create]; set RA_RC_3_8 [pw::Connector create]; set RA_RC_3_9 [pw::Connector create];
set RA_RC_3_10 [pw::Connector create]; set RA_RC_3_11 [pw::Connector create]; set RA_RC_3_12 [pw::Connector create]
# seg variable add in line variable
$RA_RC_3_1 addSegment $seg901;    $RA_RC_3_2 addSegment $seg902;   $RA_RC_3_3 addSegment $seg903;  
$RA_RC_3_4 addSegment $seg904;    $RA_RC_3_5 addSegment $seg905;   $RA_RC_3_6 addSegment $seg906;  
$RA_RC_3_7 addSegment $seg907;    $RA_RC_3_8 addSegment $seg908;   $RA_RC_3_9 addSegment $seg909;    
$RA_RC_3_10 addSegment $seg910;   $RA_RC_3_11 addSegment $seg911;  $RA_RC_3_12 addSegment $seg912;
# It's creating line 113 points
$RA_RC_3_1 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_2 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_3 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_3_4 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_5 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_6 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; 
$RA_RC_3_7 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_8 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_9 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];
$RA_RC_3_10 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_11 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"]; $RA_RC_3_12 setDimension [expr "4*$NUMBER_OF_CONNECTORS - 10"];

$RA_RC_3_1 setName RA_RC_3_1; $RA_RC_3_2 setName RA_RC_3_2; $RA_RC_3_3 setName RA_RC_3_3; $RA_RC_3_4 setName RA_RC_3_4;
$RA_RC_3_5 setName RA_RC_3_5; $RA_RC_3_6 setName RA_RC_3_6; $RA_RC_3_7 setName RA_RC_3_7; $RA_RC_3_8 setName RA_RC_3_8;
$RA_RC_3_9 setName RA_RC_3_9; $RA_RC_3_10 setName RA_RC_3_10; $RA_RC_3_11 setName RA_RC_3_11; $RA_RC_3_12 setName RA_RC_3_12;

$CREATE_A_LINE_BETWEEN_LEADING_EDGE_AIRFOIL_AND_LEADING_EDGE_CYLINDER end

set S_C_L_B_RA_LA_3_1 [pw::Application begin Modify [list $RA_RC_3_1]]
  set S_L_3_1 [$RA_RC_3_1 getDistribution 1]
  $S_L_3_1 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_3_1 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_1 end

set S_C_L_B_RA_LA_3_2 [pw::Application begin Modify [list $RA_RC_3_2]]
  set S_L_3_2 [$RA_RC_3_2 getDistribution 1]
  $S_L_3_2 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_3_2 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_2 end

set S_C_L_B_RA_LA_3_3 [pw::Application begin Modify [list $RA_RC_3_3]]
  set S_L_3_3 [$RA_RC_3_3 getDistribution 1]
  $S_L_3_3 setBeginSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
  $S_L_3_3 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_3 end

set S_C_L_B_RA_LA_3_4 [pw::Application begin Modify [list $RA_RC_3_4]]
  set S_L_3_4 [$RA_RC_3_4 getDistribution 1]
  $S_L_3_4 setBeginSpacing 0.08
  $S_L_3_4 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_4 end

set S_C_L_B_RA_LA_3_5 [pw::Application begin Modify [list $RA_RC_3_5]]
  set S_L_3_5 [$RA_RC_3_5 getDistribution 1]
  $S_L_3_5 setBeginSpacing 0.15
  $S_L_3_5 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_5 end

set S_C_L_B_RA_LA_3_6 [pw::Application begin Modify [list $RA_RC_3_6]]
  set S_L_3_6 [$RA_RC_3_6 getDistribution 1]
  $S_L_3_6 setBeginSpacing 0.2
  $S_L_3_6 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_6 end

set S_C_L_B_RA_LA_3_7 [pw::Application begin Modify [list $RA_RC_3_7]]
  set S_L_3_7 [$RA_RC_3_7 getDistribution 1]
  $S_L_3_7 setBeginSpacing 0.433
  $S_L_3_7 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_7 end

set S_C_L_B_RA_LA_3_8 [pw::Application begin Modify [list $RA_RC_3_8]]
  set S_L_3_8 [$RA_RC_3_8 getDistribution 1]
  $S_L_3_8 setBeginSpacing 0.4101
  $S_L_3_8 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_8 end

set S_C_L_B_RA_LA_3_9 [pw::Application begin Modify [list $RA_RC_3_9]]
  set S_L_3_9 [$RA_RC_3_9 getDistribution 1]
  $S_L_3_9 setBeginSpacing 0.41383
  $S_L_3_9 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_9 end

set S_C_L_B_RA_LA_3_10 [pw::Application begin Modify [list $RA_RC_3_10]]
  set S_L_3_10 [$RA_RC_3_10 getDistribution 1]
  $S_L_3_10 setBeginSpacing 0.502
  $S_L_3_10 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_10 end

set S_C_L_B_RA_LA_3_11 [pw::Application begin Modify [list $RA_RC_3_11]]
  set S_L_3_11 [$RA_RC_3_11 getDistribution 1]
  $S_L_3_11 setBeginSpacing 0.503
  $S_L_3_11 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_11 end

set S_C_L_B_RA_LA_3_12 [pw::Application begin Modify [list $RA_RC_3_12]]
  set S_L_3_12 [$RA_RC_3_12 getDistribution 1]
  $S_L_3_12 setBeginSpacing 0.5048
  $S_L_3_12 setEndSpacing [expr "$SPACING_CONSTRAINT_VALUE"]
$S_C_L_B_RA_LA_3_12 end

# ----------------------------------------------------------------------------------------------
# CREATE THE DOMAIN FOR STRUCTURE CYLINDER OUTSIDE OF AIRFOIL
# C_D_179_D_C = CREATE A DOMAIN FOR 179 DEGREE OF CIRCLE ROOTSIDE
# ----------------------------------------------------------------------------------------------

set CREATE_A_STRUCTURE_DOMAIN_OF_ROODIDE_BETWEEN_ROOTAIRFOIL_AND_ROOTSIDE_CIRCLE [pw::Application begin Create]

set C_D_179_D_C_RS_1 [pw::Edge create];    $C_D_179_D_C_RS_1 addConnector $CREATE_A_ROOT_SIDE_PRESSURE_OUTSIDE_AIRFOIL
set C_D_179_D_C_RS_2 [pw::Edge create];    $C_D_179_D_C_RS_2 addConnector $CL3
set C_D_179_D_C_RS_3 [pw::Edge create];    $C_D_179_D_C_RS_3 addConnector $CREATE_FIRST_179_DEGREE_CIRCLE
set C_D_179_D_C_RS_4 [pw::Edge create];    $C_D_179_D_C_RS_4 addConnector $CL1
set DOM_18 [pw::DomainStructured create]
$DOM_18 addEdge $C_D_179_D_C_RS_1;          $DOM_18 addEdge $C_D_179_D_C_RS_2;
$DOM_18 addEdge $C_D_179_D_C_RS_3;          $DOM_18 addEdge $C_D_179_D_C_RS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_18 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_18 setName 179_RS_DOM_18

set C_D_122_D_C_RS_1 [pw::Edge create];    $C_D_122_D_C_RS_1 addConnector $CREATE_A_ROOT_SIDE_PRESSURE_INLET_AIRFOIL
set C_D_122_D_C_RS_2 [pw::Edge create];    $C_D_122_D_C_RS_2 addConnector $CL3
set C_D_122_D_C_RS_3 [pw::Edge create];    $C_D_122_D_C_RS_3 addConnector $CREATE_FIRST_122_DEGREE_CIRCLE
set C_D_122_D_C_RS_4 [pw::Edge create];    $C_D_122_D_C_RS_4 addConnector $CL2
set DOM_19 [pw::DomainStructured create]
$DOM_19 addEdge $C_D_122_D_C_RS_1;          $DOM_19 addEdge $C_D_122_D_C_RS_2;
$DOM_19 addEdge $C_D_122_D_C_RS_3;          $DOM_19 addEdge $C_D_122_D_C_RS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_19 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_19 setName 122_RS_DOM_19

set C_D_59_D_C_RS_1 [pw::Edge create];     $C_D_59_D_C_RS_1 addConnector $N_C_L_B_T_E
set C_D_59_D_C_RS_2 [pw::Edge create];     $C_D_59_D_C_RS_2 addConnector $CL1
set C_D_59_D_C_RS_3 [pw::Edge create];     $C_D_59_D_C_RS_3 addConnector $CREATE_FIRST_59_DEGREE_CIRCLE
set C_D_59_D_C_RS_4 [pw::Edge create];     $C_D_59_D_C_RS_4 addConnector $CL2
set DOM_20 [pw::DomainStructured create]
$DOM_20 addEdge $C_D_59_D_C_RS_1;          $DOM_20 addEdge $C_D_59_D_C_RS_2;
$DOM_20 addEdge $C_D_59_D_C_RS_3;          $DOM_20 addEdge $C_D_59_D_C_RS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_20 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_20 setName 59_RS_DOM_20

$CREATE_A_STRUCTURE_DOMAIN_OF_ROODIDE_BETWEEN_ROOTAIRFOIL_AND_ROOTSIDE_CIRCLE end

# CREATE THE DOMAIN FOR STRUCTURE CYLINDER OUTSIDE OF AIRFOIL
# C_D_179_D_C = CREATE A DOMAIN FOR 179 DEGREE OF CIRCLE TIPSIDE

set CREATE_A_STRUCTURE_DOMAIN_OF_ROODIDE_BETWEEN_TIPAIRFOIL_AND_TIPSIDE_CIRCLE [pw::Application begin Create]

set C_D_179_D_C_TS_1 [pw::Edge create];    $C_D_179_D_C_TS_1 addConnector $P_I_T_S
set C_D_179_D_C_TS_2 [pw::Edge create];    $C_D_179_D_C_TS_2 addConnector $CL4
set C_D_179_D_C_TS_3 [pw::Edge create];    $C_D_179_D_C_TS_3 addConnector $CREATE_FIRST_179_DEGREE_CIRCLE_TS
set C_D_179_D_C_TS_4 [pw::Edge create];    $C_D_179_D_C_TS_4 addConnector $CL6
set DOM_21 [pw::DomainStructured create]
$DOM_21 addEdge $C_D_179_D_C_TS_1;          $DOM_21 addEdge $C_D_179_D_C_TS_2;
$DOM_21 addEdge $C_D_179_D_C_TS_3;          $DOM_21 addEdge $C_D_179_D_C_TS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_21 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_21 setName 179_TS_DOM_21

set C_D_122_D_C_TS_1 [pw::Edge create];     $C_D_122_D_C_TS_1 addConnector $P_O_T_S_L_E
set C_D_122_D_C_TS_2 [pw::Edge create];     $C_D_122_D_C_TS_2 addConnector $CL5
set C_D_122_D_C_TS_3 [pw::Edge create];     $C_D_122_D_C_TS_3 addConnector $CREATE_FIRST_122_DEGREE_CIRCLE_TS
set C_D_122_D_C_TS_4 [pw::Edge create];     $C_D_122_D_C_TS_4 addConnector $CL6
set DOM_22 [pw::DomainStructured create]
$DOM_22 addEdge $C_D_122_D_C_TS_1;          $DOM_22 addEdge $C_D_122_D_C_TS_2;
$DOM_22 addEdge $C_D_122_D_C_TS_3;          $DOM_22 addEdge $C_D_122_D_C_TS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_22 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_22 setName 122_TS_DOM_22

set C_D_59_D_C_TS_1 [pw::Edge create];      $C_D_59_D_C_TS_1 addConnector $T_E_T_S;
set C_D_59_D_C_TS_2 [pw::Edge create];      $C_D_59_D_C_TS_2 addConnector $CL5;
set C_D_59_D_C_TS_3 [pw::Edge create];      $C_D_59_D_C_TS_3 addConnector $CREATE_FIRST_59_DEGREE_CIRCLE_TS;
set C_D_59_D_C_TS_4 [pw::Edge create];      $C_D_59_D_C_TS_4 addConnector $CL4;
set DOM_23 [pw::DomainStructured create]
$DOM_23 addEdge $C_D_59_D_C_TS_1;          $DOM_23 addEdge $C_D_59_D_C_TS_2;
$DOM_23 addEdge $C_D_59_D_C_TS_3;          $DOM_23 addEdge $C_D_59_D_C_TS_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_23 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_23 setName 59_RS_DOM_23

$CREATE_A_STRUCTURE_DOMAIN_OF_ROODIDE_BETWEEN_TIPAIRFOIL_AND_TIPSIDE_CIRCLE end

# CREATE A DOMAIN BETWEEN ROOTSIDE AND TIPSIDE AIRFOIL
# T_E_P_I_S = TRAILING EDGE PRESSURE INLET SIDE 
# T_E_P_O_S = TRAILING EDGE PRESSURE OUTLET SIDE
# L_E_S = LEADING EDGE SIDE

set CREATE_A_STRUCTURE_DOMAIN_BETWEEN_ROODIDE_AND_TIPSIDE_AIRFOIL [pw::Application begin Create]
 
set  T_E_P_I_S_1_1 [pw::Edge create];       $T_E_P_I_S_1_1 addConnector $CL2
set T_E_P_I_S_2_1 [pw::Edge create];        $T_E_P_I_S_2_1 addConnector $LINE_2_SPLIT_1
set T_E_P_I_S_3_1 [pw::Edge create];        $T_E_P_I_S_3_1 addConnector $RA_RC_2_1
set T_E_P_I_S_4_1 [pw::Edge create];        $T_E_P_I_S_4_1 addConnector $TRAILING_EDGE_POINT_OF_PRESSURE_OUTLET_SIDE
set DOM_24 [pw::DomainStructured create]
$DOM_24 addEdge $T_E_P_I_S_1_1;          $DOM_24 addEdge $T_E_P_I_S_2_1;
$DOM_24 addEdge $T_E_P_I_S_3_1;          $DOM_24 addEdge $T_E_P_I_S_4_1;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_24 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_24 setName TE_IPS_DOM_24

set T_E_P_I_S_1_2 [pw::Edge create];        $T_E_P_I_S_1_2 addConnector $RA_RC_2_1
set T_E_P_I_S_2_2 [pw::Edge create];        $T_E_P_I_S_2_2 addConnector $LINE_2_SPLIT_2
set T_E_P_I_S_3_2 [pw::Edge create];        $T_E_P_I_S_3_2 addConnector $RA_RC_2_2
set T_E_P_I_S_4_2 [pw::Edge create];        $T_E_P_I_S_4_2 addConnector $TE_P_IS_2
set DOM_25 [pw::DomainStructured create]
$DOM_25 addEdge $T_E_P_I_S_1_2;          $DOM_25 addEdge $T_E_P_I_S_2_2;
$DOM_25 addEdge $T_E_P_I_S_3_2;          $DOM_25 addEdge $T_E_P_I_S_4_2;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_25 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_25 setName TE_IPS_DOM_25

set T_E_P_I_S_1_3 [pw::Edge create];        $T_E_P_I_S_1_3 addConnector $RA_RC_2_2
set T_E_P_I_S_2_3 [pw::Edge create];        $T_E_P_I_S_2_3 addConnector $LINE_2_SPLIT_3
set T_E_P_I_S_3_3 [pw::Edge create];        $T_E_P_I_S_3_3 addConnector $RA_RC_2_3
set T_E_P_I_S_4_3 [pw::Edge create];        $T_E_P_I_S_4_3 addConnector $TE_P_IS_3
set DOM_26 [pw::DomainStructured create]
$DOM_26 addEdge $T_E_P_I_S_1_3;          $DOM_26 addEdge $T_E_P_I_S_2_3;
$DOM_26 addEdge $T_E_P_I_S_3_3;          $DOM_26 addEdge $T_E_P_I_S_4_3;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_26 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_26 setName TE_IPS_DOM_26

set T_E_P_I_S_1_4 [pw::Edge create];        $T_E_P_I_S_1_4 addConnector $RA_RC_2_3
set T_E_P_I_S_2_4 [pw::Edge create];        $T_E_P_I_S_2_4 addConnector $LINE_2_SPLIT_4
set T_E_P_I_S_3_4 [pw::Edge create];        $T_E_P_I_S_3_4 addConnector $RA_RC_2_4
set T_E_P_I_S_4_4 [pw::Edge create];        $T_E_P_I_S_4_4 addConnector $TE_P_IS_4
set DOM_27 [pw::DomainStructured create]
$DOM_27 addEdge $T_E_P_I_S_1_4;          $DOM_27 addEdge $T_E_P_I_S_2_4;
$DOM_27 addEdge $T_E_P_I_S_3_4;          $DOM_27 addEdge $T_E_P_I_S_4_4;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_27 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_27 setName TE_IPS_DOM_27

set T_E_P_I_S_1_5 [pw::Edge create];        $T_E_P_I_S_1_5 addConnector $RA_RC_2_4
set T_E_P_I_S_2_5 [pw::Edge create];        $T_E_P_I_S_2_5 addConnector $LINE_2_SPLIT_5
set T_E_P_I_S_3_5 [pw::Edge create];        $T_E_P_I_S_3_5 addConnector $RA_RC_2_5
set T_E_P_I_S_4_5 [pw::Edge create];        $T_E_P_I_S_4_5 addConnector $TE_P_IS_5
set DOM_28 [pw::DomainStructured create]
$DOM_28 addEdge $T_E_P_I_S_1_5;          $DOM_28 addEdge $T_E_P_I_S_2_5;
$DOM_28 addEdge $T_E_P_I_S_3_5;          $DOM_28 addEdge $T_E_P_I_S_4_5;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_28 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_28 setName TE_IPS_DOM_28

set T_E_P_I_S_1_6 [pw::Edge create];        $T_E_P_I_S_1_6 addConnector $RA_RC_2_5
set T_E_P_I_S_2_6 [pw::Edge create];        $T_E_P_I_S_2_6 addConnector $LINE_2_SPLIT_6
set T_E_P_I_S_3_6 [pw::Edge create];        $T_E_P_I_S_3_6 addConnector $RA_RC_2_6
set T_E_P_I_S_4_6 [pw::Edge create];        $T_E_P_I_S_4_6 addConnector $TE_P_IS_6
set DOM_29 [pw::DomainStructured create]
$DOM_29 addEdge $T_E_P_I_S_1_6;          $DOM_29 addEdge $T_E_P_I_S_2_6;
$DOM_29 addEdge $T_E_P_I_S_3_6;          $DOM_29 addEdge $T_E_P_I_S_4_6;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_29 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_29 setName TE_IPS_DOM_29

set T_E_P_I_S_1_7 [pw::Edge create];        $T_E_P_I_S_1_7 addConnector $RA_RC_2_6
set T_E_P_I_S_2_7 [pw::Edge create];        $T_E_P_I_S_2_7 addConnector $LINE_2_SPLIT_7
set T_E_P_I_S_3_7 [pw::Edge create];        $T_E_P_I_S_3_7 addConnector $RA_RC_2_7
set T_E_P_I_S_4_7 [pw::Edge create];        $T_E_P_I_S_4_7 addConnector $TE_P_IS_7
set DOM_30 [pw::DomainStructured create]
$DOM_30 addEdge $T_E_P_I_S_1_7;          $DOM_30 addEdge $T_E_P_I_S_2_7;
$DOM_30 addEdge $T_E_P_I_S_3_7;          $DOM_30 addEdge $T_E_P_I_S_4_7;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_30 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_30 setName TE_IPS_DOM_30

set T_E_P_I_S_1_8 [pw::Edge create];        $T_E_P_I_S_1_8 addConnector $RA_RC_2_7
set T_E_P_I_S_2_8 [pw::Edge create];        $T_E_P_I_S_2_8 addConnector $LINE_2_SPLIT_8
set T_E_P_I_S_3_8 [pw::Edge create];        $T_E_P_I_S_3_8 addConnector $RA_RC_2_8
set T_E_P_I_S_4_8 [pw::Edge create];        $T_E_P_I_S_4_8 addConnector $TE_P_IS_8
set DOM_31 [pw::DomainStructured create]
$DOM_31 addEdge $T_E_P_I_S_1_8;          $DOM_31 addEdge $T_E_P_I_S_2_8;
$DOM_31 addEdge $T_E_P_I_S_3_8;          $DOM_31 addEdge $T_E_P_I_S_4_8;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_31 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_31 setName TE_IPS_DOM_31

set T_E_P_I_S_1_9 [pw::Edge create];        $T_E_P_I_S_1_9 addConnector $RA_RC_2_8
set T_E_P_I_S_2_9 [pw::Edge create];        $T_E_P_I_S_2_9 addConnector $LINE_2_SPLIT_9
set T_E_P_I_S_3_9 [pw::Edge create];        $T_E_P_I_S_3_9 addConnector $RA_RC_2_9
set T_E_P_I_S_4_9 [pw::Edge create];        $T_E_P_I_S_4_9 addConnector $TE_P_IS_9
set DOM_32 [pw::DomainStructured create]
$DOM_32 addEdge $T_E_P_I_S_1_9;          $DOM_32 addEdge $T_E_P_I_S_2_9;
$DOM_32 addEdge $T_E_P_I_S_3_9;          $DOM_32 addEdge $T_E_P_I_S_4_9;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_32 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_32 setName TE_IPS_DOM_32

set T_E_P_I_S_1_10 [pw::Edge create];        $T_E_P_I_S_1_10 addConnector $RA_RC_2_9
set T_E_P_I_S_2_10 [pw::Edge create];        $T_E_P_I_S_2_10 addConnector $LINE_2_SPLIT_10
set T_E_P_I_S_3_10 [pw::Edge create];        $T_E_P_I_S_3_10 addConnector $RA_RC_2_10
set T_E_P_I_S_4_10 [pw::Edge create];        $T_E_P_I_S_4_10 addConnector $TE_P_IS_10
set DOM_33 [pw::DomainStructured create]
$DOM_33 addEdge $T_E_P_I_S_1_10;          $DOM_33 addEdge $T_E_P_I_S_2_10;
$DOM_33 addEdge $T_E_P_I_S_3_10;          $DOM_33 addEdge $T_E_P_I_S_4_10;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_33 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_33 setName TE_IPS_DOM_33

set T_E_P_I_S_1_11 [pw::Edge create];        $T_E_P_I_S_1_11 addConnector $RA_RC_2_10
set T_E_P_I_S_2_11 [pw::Edge create];        $T_E_P_I_S_2_11 addConnector $LINE_2_SPLIT_11
set T_E_P_I_S_3_11 [pw::Edge create];        $T_E_P_I_S_3_11 addConnector $RA_RC_2_11
set T_E_P_I_S_4_11 [pw::Edge create];        $T_E_P_I_S_4_11 addConnector $TE_P_IS_11
set DOM_34 [pw::DomainStructured create]
$DOM_34 addEdge $T_E_P_I_S_1_11;          $DOM_34 addEdge $T_E_P_I_S_2_11;
$DOM_34 addEdge $T_E_P_I_S_3_11;          $DOM_34 addEdge $T_E_P_I_S_4_11;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_34 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_34 setName TE_IPS_DOM_34

set T_E_P_I_S_1_12 [pw::Edge create];        $T_E_P_I_S_1_12 addConnector $RA_RC_2_11
set T_E_P_I_S_2_12 [pw::Edge create];        $T_E_P_I_S_2_12 addConnector $LINE_2_SPLIT_12
set T_E_P_I_S_3_12 [pw::Edge create];        $T_E_P_I_S_3_12 addConnector $RA_RC_2_12
set T_E_P_I_S_4_12 [pw::Edge create];        $T_E_P_I_S_4_12 addConnector $TE_P_IS_12
set DOM_35 [pw::DomainStructured create]
$DOM_35 addEdge $T_E_P_I_S_1_12;          $DOM_35 addEdge $T_E_P_I_S_2_12;
$DOM_35 addEdge $T_E_P_I_S_3_12;          $DOM_35 addEdge $T_E_P_I_S_4_12;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_35 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_35 setName TE_IPS_DOM_35

set T_E_P_I_S_1_13 [pw::Edge create];        $T_E_P_I_S_1_13 addConnector $RA_RC_2_12
set T_E_P_I_S_2_13 [pw::Edge create];        $T_E_P_I_S_2_13 addConnector $LINE_2_SPLIT_13
set T_E_P_I_S_3_13 [pw::Edge create];        $T_E_P_I_S_3_13 addConnector $CL5
set T_E_P_I_S_4_13 [pw::Edge create];        $T_E_P_I_S_4_13 addConnector $TE_P_IS_13
set DOM_36 [pw::DomainStructured create]
$DOM_36 addEdge $T_E_P_I_S_1_13;          $DOM_36 addEdge $T_E_P_I_S_2_13;
$DOM_36 addEdge $T_E_P_I_S_3_13;          $DOM_36 addEdge $T_E_P_I_S_4_13;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_36 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_36 setName TE_IPS_DOM_36

set  T_E_P_O_S_1_1 [pw::Edge create];         $T_E_P_O_S_1_1 addConnector $CL1
set T_E_P_O_S_2_1 [pw::Edge create];          $T_E_P_O_S_2_1 addConnector $LINE_3_SPLIT_1
set T_E_P_O_S_3_1 [pw::Edge create];          $T_E_P_O_S_3_1 addConnector $RA_RC_1_1
set T_E_P_O_S_4_1 [pw::Edge create];          $T_E_P_O_S_4_1 addConnector $N_C_T_P_O_S_1
set DOM_37 [pw::DomainStructured create]
$DOM_37 addEdge $T_E_P_O_S_1_1;          $DOM_37 addEdge $T_E_P_O_S_2_1;
$DOM_37 addEdge $T_E_P_O_S_3_1;          $DOM_37 addEdge $T_E_P_O_S_4_1;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_37 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_37 setName TE_OPS_DOM_37

set T_E_P_O_S_1_2 [pw::Edge create];        $T_E_P_O_S_1_2 addConnector $RA_RC_1_1
set T_E_P_O_S_2_2 [pw::Edge create];        $T_E_P_O_S_2_2 addConnector $LINE_3_SPLIT_2
set T_E_P_O_S_3_2 [pw::Edge create];        $T_E_P_O_S_3_2 addConnector $RA_RC_1_2
set T_E_P_O_S_4_2 [pw::Edge create];        $T_E_P_O_S_4_2 addConnector $N_C_T_P_O_S_2
set DOM_38 [pw::DomainStructured create]
$DOM_38 addEdge $T_E_P_O_S_1_2;          $DOM_38 addEdge $T_E_P_O_S_2_2;
$DOM_38 addEdge $T_E_P_O_S_3_2;          $DOM_38 addEdge $T_E_P_O_S_4_2;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_38 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_38 setName TE_OPS_DOM_38

set T_E_P_O_S_1_3 [pw::Edge create];        $T_E_P_O_S_1_3 addConnector $RA_RC_1_2
set T_E_P_O_S_2_3 [pw::Edge create];        $T_E_P_O_S_2_3 addConnector $LINE_3_SPLIT_3
set T_E_P_O_S_3_3 [pw::Edge create];        $T_E_P_O_S_3_3 addConnector $RA_RC_1_3
set T_E_P_O_S_4_3 [pw::Edge create];        $T_E_P_O_S_4_3 addConnector $N_C_T_P_O_S_3
set DOM_39 [pw::DomainStructured create]
$DOM_39 addEdge $T_E_P_O_S_1_3;          $DOM_39 addEdge $T_E_P_O_S_2_3;
$DOM_39 addEdge $T_E_P_O_S_3_3;          $DOM_39 addEdge $T_E_P_O_S_4_3;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_39 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_39 setName TE_OPS_DOM_39

set T_E_P_O_S_1_4 [pw::Edge create];        $T_E_P_O_S_1_4 addConnector $RA_RC_1_3
set T_E_P_O_S_2_4 [pw::Edge create];        $T_E_P_O_S_2_4 addConnector $LINE_3_SPLIT_4
set T_E_P_O_S_3_4 [pw::Edge create];        $T_E_P_O_S_3_4 addConnector $RA_RC_1_4
set T_E_P_O_S_4_4 [pw::Edge create];        $T_E_P_O_S_4_4 addConnector $N_C_T_P_O_S_4
set DOM_40 [pw::DomainStructured create]
$DOM_40 addEdge $T_E_P_O_S_1_4;          $DOM_40 addEdge $T_E_P_O_S_2_4;
$DOM_40 addEdge $T_E_P_O_S_3_4;          $DOM_40 addEdge $T_E_P_O_S_4_4;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_40 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_40 setName TE_OPS_DOM_40

set T_E_P_O_S_1_5 [pw::Edge create];        $T_E_P_O_S_1_5 addConnector $RA_RC_1_4
set T_E_P_O_S_2_5 [pw::Edge create];        $T_E_P_O_S_2_5 addConnector $LINE_3_SPLIT_5
set T_E_P_O_S_3_5 [pw::Edge create];        $T_E_P_O_S_3_5 addConnector $RA_RC_1_5
set T_E_P_O_S_4_5 [pw::Edge create];        $T_E_P_O_S_4_5 addConnector $N_C_T_P_O_S_5
set DOM_41 [pw::DomainStructured create]
$DOM_41 addEdge $T_E_P_O_S_1_5;          $DOM_41 addEdge $T_E_P_O_S_2_5;
$DOM_41 addEdge $T_E_P_O_S_3_5;          $DOM_41 addEdge $T_E_P_O_S_4_5;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_41 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_41 setName TE_OPS_DOM_41

set T_E_P_O_S_1_6 [pw::Edge create];        $T_E_P_O_S_1_6 addConnector $RA_RC_1_5
set T_E_P_O_S_2_6 [pw::Edge create];        $T_E_P_O_S_2_6 addConnector $LINE_3_SPLIT_6
set T_E_P_O_S_3_6 [pw::Edge create];        $T_E_P_O_S_3_6 addConnector $RA_RC_1_6
set T_E_P_O_S_4_6 [pw::Edge create];        $T_E_P_O_S_4_6 addConnector $N_C_T_P_O_S_6
set DOM_42 [pw::DomainStructured create]
$DOM_42 addEdge $T_E_P_O_S_1_6;          $DOM_42 addEdge $T_E_P_O_S_2_6;
$DOM_42 addEdge $T_E_P_O_S_3_6;          $DOM_42 addEdge $T_E_P_O_S_4_6;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_42 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_42 setName TE_OPS_DOM_42

set T_E_P_O_S_1_7 [pw::Edge create];        $T_E_P_O_S_1_7 addConnector $RA_RC_1_6
set T_E_P_O_S_2_7 [pw::Edge create];        $T_E_P_O_S_2_7 addConnector $LINE_3_SPLIT_7
set T_E_P_O_S_3_7 [pw::Edge create];        $T_E_P_O_S_3_7 addConnector $RA_RC_1_7
set T_E_P_O_S_4_7 [pw::Edge create];        $T_E_P_O_S_4_7 addConnector $N_C_T_P_O_S_7
set DOM_43 [pw::DomainStructured create]
$DOM_43 addEdge $T_E_P_O_S_1_7;          $DOM_43 addEdge $T_E_P_O_S_2_7;
$DOM_43 addEdge $T_E_P_O_S_3_7;          $DOM_43 addEdge $T_E_P_O_S_4_7;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_43 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_43 setName TE_OPS_DOM_43

set T_E_P_O_S_1_8 [pw::Edge create];        $T_E_P_O_S_1_8 addConnector $RA_RC_1_7
set T_E_P_O_S_2_8 [pw::Edge create];        $T_E_P_O_S_2_8 addConnector $LINE_3_SPLIT_8
set T_E_P_O_S_3_8 [pw::Edge create];        $T_E_P_O_S_3_8 addConnector $RA_RC_1_8
set T_E_P_O_S_4_8 [pw::Edge create];        $T_E_P_O_S_4_8 addConnector $N_C_T_P_O_S_8
set DOM_44 [pw::DomainStructured create]
$DOM_44 addEdge $T_E_P_O_S_1_8;          $DOM_44 addEdge $T_E_P_O_S_2_8;
$DOM_44 addEdge $T_E_P_O_S_3_8;          $DOM_44 addEdge $T_E_P_O_S_4_8;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_44 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_44 setName TE_OPS_DOM_44

set T_E_P_O_S_1_9 [pw::Edge create];        $T_E_P_O_S_1_9 addConnector $RA_RC_1_8
set T_E_P_O_S_2_9 [pw::Edge create];        $T_E_P_O_S_2_9 addConnector $LINE_3_SPLIT_9
set T_E_P_O_S_3_9 [pw::Edge create];        $T_E_P_O_S_3_9 addConnector $RA_RC_1_9
set T_E_P_O_S_4_9 [pw::Edge create];        $T_E_P_O_S_4_9 addConnector $N_C_T_P_O_S_9
set DOM_45 [pw::DomainStructured create]
$DOM_45 addEdge $T_E_P_O_S_1_9;          $DOM_45 addEdge $T_E_P_O_S_2_9;
$DOM_45 addEdge $T_E_P_O_S_3_9;          $DOM_45 addEdge $T_E_P_O_S_4_9;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_45 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_45 setName TE_OPS_DOM_45

set T_E_P_O_S_1_10 [pw::Edge create];        $T_E_P_O_S_1_10 addConnector $RA_RC_1_9
set T_E_P_O_S_2_10 [pw::Edge create];        $T_E_P_O_S_2_10 addConnector $LINE_3_SPLIT_10
set T_E_P_O_S_3_10 [pw::Edge create];        $T_E_P_O_S_3_10 addConnector $RA_RC_1_10
set T_E_P_O_S_4_10 [pw::Edge create];        $T_E_P_O_S_4_10 addConnector $N_C_T_P_O_S_10
set DOM_46 [pw::DomainStructured create]
$DOM_46 addEdge $T_E_P_O_S_1_10;          $DOM_46 addEdge $T_E_P_O_S_2_10;
$DOM_46 addEdge $T_E_P_O_S_3_10;          $DOM_46 addEdge $T_E_P_O_S_4_10;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_46 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_46 setName TE_OPS_DOM_46

set T_E_P_O_S_1_11 [pw::Edge create];        $T_E_P_O_S_1_11 addConnector $RA_RC_1_10
set T_E_P_O_S_2_11 [pw::Edge create];        $T_E_P_O_S_2_11 addConnector $LINE_3_SPLIT_11
set T_E_P_O_S_3_11 [pw::Edge create];        $T_E_P_O_S_3_11 addConnector $RA_RC_1_11
set T_E_P_O_S_4_11 [pw::Edge create];        $T_E_P_O_S_4_11 addConnector $N_C_T_P_O_S_11
set DOM_47 [pw::DomainStructured create]
$DOM_47 addEdge $T_E_P_O_S_1_11;          $DOM_47 addEdge $T_E_P_O_S_2_11;
$DOM_47 addEdge $T_E_P_O_S_3_11;          $DOM_47 addEdge $T_E_P_O_S_4_11;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_47 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_47 setName TE_OPS_DOM_47

set T_E_P_O_S_1_12 [pw::Edge create];        $T_E_P_O_S_1_12 addConnector $RA_RC_1_11
set T_E_P_O_S_2_12 [pw::Edge create];        $T_E_P_O_S_2_12 addConnector $LINE_3_SPLIT_12
set T_E_P_O_S_3_12 [pw::Edge create];        $T_E_P_O_S_3_12 addConnector $RA_RC_1_12
set T_E_P_O_S_4_12 [pw::Edge create];        $T_E_P_O_S_4_12 addConnector $N_C_T_P_O_S_12
set DOM_48 [pw::DomainStructured create]
$DOM_48 addEdge $T_E_P_O_S_1_12;          $DOM_48 addEdge $T_E_P_O_S_2_12;
$DOM_48 addEdge $T_E_P_O_S_3_12;          $DOM_48 addEdge $T_E_P_O_S_4_12;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_48 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_48 setName TE_OPS_DOM_48

set T_E_P_O_S_1_13 [pw::Edge create];        $T_E_P_O_S_1_13 addConnector $RA_RC_1_12
set T_E_P_O_S_2_13 [pw::Edge create];        $T_E_P_O_S_2_13 addConnector $LINE_3_SPLIT_13
set T_E_P_O_S_3_13 [pw::Edge create];        $T_E_P_O_S_3_13 addConnector $CL4
set T_E_P_O_S_4_13 [pw::Edge create];        $T_E_P_O_S_4_13 addConnector $TE_P_OS_12
set DOM_49 [pw::DomainStructured create]
$DOM_49 addEdge $T_E_P_O_S_1_13;          $DOM_49 addEdge $T_E_P_O_S_2_13;
$DOM_49 addEdge $T_E_P_O_S_3_13;          $DOM_49 addEdge $T_E_P_O_S_4_13;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_49 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_49 setName TE_OPS_DOM_49

set L_E_S_E_1_1 [pw::Edge create];        $L_E_S_E_1_1 addConnector $CL3
set L_E_S_E_2_1 [pw::Edge create];        $L_E_S_E_2_1 addConnector $LINE_1_SPLIT_1
set L_E_S_E_3_1 [pw::Edge create];        $L_E_S_E_3_1 addConnector $RA_RC_3_1
set L_E_S_E_4_1 [pw::Edge create];        $L_E_S_E_4_1 addConnector $N_C_L_E_1
set DOM_50 [pw::DomainStructured create]
$DOM_50 addEdge $L_E_S_E_1_1;          $DOM_50 addEdge $L_E_S_E_2_1;
$DOM_50 addEdge $L_E_S_E_3_1;          $DOM_50 addEdge $L_E_S_E_4_1;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_50 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_50 setName LE_DOM_50

set L_E_S_E_1_2 [pw::Edge create];        $L_E_S_E_1_2 addConnector $RA_RC_3_1
set L_E_S_E_2_2 [pw::Edge create];        $L_E_S_E_2_2 addConnector $LINE_1_SPLIT_2
set L_E_S_E_3_2 [pw::Edge create];        $L_E_S_E_3_2 addConnector $RA_RC_3_2
set L_E_S_E_4_2 [pw::Edge create];        $L_E_S_E_4_2 addConnector $N_C_L_E_2
set DOM_51 [pw::DomainStructured create]
$DOM_51 addEdge $L_E_S_E_1_2;          $DOM_51 addEdge $L_E_S_E_2_2;
$DOM_51 addEdge $L_E_S_E_3_2;          $DOM_51 addEdge $L_E_S_E_4_2;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_51 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_51 setName LE_DOM_51

set L_E_S_E_1_3 [pw::Edge create];        $L_E_S_E_1_3 addConnector $RA_RC_3_2
set L_E_S_E_2_3 [pw::Edge create];        $L_E_S_E_2_3 addConnector $LINE_1_SPLIT_3
set L_E_S_E_3_3 [pw::Edge create];        $L_E_S_E_3_3 addConnector $RA_RC_3_3
set L_E_S_E_4_3 [pw::Edge create];        $L_E_S_E_4_3 addConnector $N_C_L_E_3
set DOM_52 [pw::DomainStructured create]
$DOM_52 addEdge $L_E_S_E_1_3;          $DOM_52 addEdge $L_E_S_E_2_3;
$DOM_52 addEdge $L_E_S_E_3_3;          $DOM_52 addEdge $L_E_S_E_4_3;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_52 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_52 setName LE_DOM_52

set L_E_S_E_1_4 [pw::Edge create];        $L_E_S_E_1_4 addConnector $RA_RC_3_3
set L_E_S_E_2_4 [pw::Edge create];        $L_E_S_E_2_4 addConnector $LINE_1_SPLIT_4
set L_E_S_E_3_4 [pw::Edge create];        $L_E_S_E_3_4 addConnector $RA_RC_3_4
set L_E_S_E_4_4 [pw::Edge create];        $L_E_S_E_4_4 addConnector $N_C_L_E_4
set DOM_53 [pw::DomainStructured create]
$DOM_53 addEdge $L_E_S_E_1_4;          $DOM_53 addEdge $L_E_S_E_2_4;
$DOM_53 addEdge $L_E_S_E_3_4;          $DOM_53 addEdge $L_E_S_E_4_4;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_53 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_53 setName LE_DOM_53

set L_E_S_E_1_5 [pw::Edge create];        $L_E_S_E_1_5 addConnector $RA_RC_3_4
set L_E_S_E_2_5 [pw::Edge create];        $L_E_S_E_2_5 addConnector $LINE_1_SPLIT_5
set L_E_S_E_3_5 [pw::Edge create];        $L_E_S_E_3_5 addConnector $RA_RC_3_5
set L_E_S_E_4_5 [pw::Edge create];        $L_E_S_E_4_5 addConnector $N_C_L_E_5
set DOM_54 [pw::DomainStructured create]
$DOM_54 addEdge $L_E_S_E_1_5;          $DOM_54 addEdge $L_E_S_E_2_5;
$DOM_54 addEdge $L_E_S_E_3_5;          $DOM_54 addEdge $L_E_S_E_4_5;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_54 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_54 setName LE_DOM_54

set L_E_S_E_1_6 [pw::Edge create];        $L_E_S_E_1_6 addConnector $RA_RC_3_5
set L_E_S_E_2_6 [pw::Edge create];        $L_E_S_E_2_6 addConnector $LINE_1_SPLIT_6
set L_E_S_E_3_6 [pw::Edge create];        $L_E_S_E_3_6 addConnector $RA_RC_3_6
set L_E_S_E_4_6 [pw::Edge create];        $L_E_S_E_4_6 addConnector $N_C_L_E_6
set DOM_55 [pw::DomainStructured create]
$DOM_55 addEdge $L_E_S_E_1_6;          $DOM_55 addEdge $L_E_S_E_2_6;
$DOM_55 addEdge $L_E_S_E_3_6;          $DOM_55 addEdge $L_E_S_E_4_6;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_55 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_55 setName LE_DOM_55

set L_E_S_E_1_7 [pw::Edge create];        $L_E_S_E_1_7 addConnector $RA_RC_3_6
set L_E_S_E_2_7 [pw::Edge create];        $L_E_S_E_2_7 addConnector $LINE_1_SPLIT_7
set L_E_S_E_3_7 [pw::Edge create];        $L_E_S_E_3_7 addConnector $RA_RC_3_7
set L_E_S_E_4_7 [pw::Edge create];        $L_E_S_E_4_7 addConnector $N_C_L_E_7
set DOM_56 [pw::DomainStructured create]
$DOM_56 addEdge $L_E_S_E_1_7;          $DOM_56 addEdge $L_E_S_E_2_7;
$DOM_56 addEdge $L_E_S_E_3_7;          $DOM_56 addEdge $L_E_S_E_4_7;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_56 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_56 setName LE_DOM_56

set L_E_S_E_1_8 [pw::Edge create];        $L_E_S_E_1_8 addConnector $RA_RC_3_7
set L_E_S_E_2_8 [pw::Edge create];        $L_E_S_E_2_8 addConnector $LINE_1_SPLIT_8
set L_E_S_E_3_8 [pw::Edge create];        $L_E_S_E_3_8 addConnector $RA_RC_3_8
set L_E_S_E_4_8 [pw::Edge create];        $L_E_S_E_4_8 addConnector $N_C_L_E_8
set DOM_57 [pw::DomainStructured create]
$DOM_57 addEdge $L_E_S_E_1_8;          $DOM_57 addEdge $L_E_S_E_2_8;
$DOM_57 addEdge $L_E_S_E_3_8;          $DOM_57 addEdge $L_E_S_E_4_8;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_57 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_57 setName LE_DOM_57

set L_E_S_E_1_9 [pw::Edge create];        $L_E_S_E_1_9 addConnector $RA_RC_3_8
set L_E_S_E_2_9 [pw::Edge create];        $L_E_S_E_2_9 addConnector $LINE_1_SPLIT_9
set L_E_S_E_3_9 [pw::Edge create];        $L_E_S_E_3_9 addConnector $RA_RC_3_9
set L_E_S_E_4_9 [pw::Edge create];        $L_E_S_E_4_9 addConnector $N_C_L_E_9
set DOM_58 [pw::DomainStructured create]
$DOM_58 addEdge $L_E_S_E_1_9;          $DOM_58 addEdge $L_E_S_E_2_9;
$DOM_58 addEdge $L_E_S_E_3_9;          $DOM_58 addEdge $L_E_S_E_4_9;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_58 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_58 setName LE_DOM_58

set L_E_S_E_1_10 [pw::Edge create];        $L_E_S_E_1_10 addConnector $RA_RC_3_9
set L_E_S_E_2_10 [pw::Edge create];        $L_E_S_E_2_10 addConnector $LINE_1_SPLIT_10
set L_E_S_E_3_10 [pw::Edge create];        $L_E_S_E_3_10 addConnector $RA_RC_3_10
set L_E_S_E_4_10 [pw::Edge create];        $L_E_S_E_4_10 addConnector $N_C_L_E_10
set DOM_59 [pw::DomainStructured create]
$DOM_59 addEdge $L_E_S_E_1_10;          $DOM_59 addEdge $L_E_S_E_2_10;
$DOM_59 addEdge $L_E_S_E_3_10;          $DOM_59 addEdge $L_E_S_E_4_10;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_59 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_59 setName LE_DOM_59

set L_E_S_E_1_11 [pw::Edge create];        $L_E_S_E_1_11 addConnector $RA_RC_3_10
set L_E_S_E_2_11 [pw::Edge create];        $L_E_S_E_2_11 addConnector $LINE_1_SPLIT_11
set L_E_S_E_3_11 [pw::Edge create];        $L_E_S_E_3_11 addConnector $RA_RC_3_11
set L_E_S_E_4_11 [pw::Edge create];        $L_E_S_E_4_11 addConnector $N_C_L_E_11
set DOM_60 [pw::DomainStructured create]
$DOM_60 addEdge $L_E_S_E_1_11;          $DOM_60 addEdge $L_E_S_E_2_11;
$DOM_60 addEdge $L_E_S_E_3_11;          $DOM_60 addEdge $L_E_S_E_4_11;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_60 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_60 setName LE_DOM_60

set L_E_S_E_1_12 [pw::Edge create];        $L_E_S_E_1_12 addConnector $RA_RC_3_11
set L_E_S_E_2_12 [pw::Edge create];        $L_E_S_E_2_12 addConnector $LINE_1_SPLIT_12
set L_E_S_E_3_12 [pw::Edge create];        $L_E_S_E_3_12 addConnector $RA_RC_3_12
set L_E_S_E_4_12 [pw::Edge create];        $L_E_S_E_4_12 addConnector $N_C_L_E_12
set DOM_61 [pw::DomainStructured create]
$DOM_61 addEdge $L_E_S_E_1_12;          $DOM_61 addEdge $L_E_S_E_2_12;
$DOM_61 addEdge $L_E_S_E_3_12;          $DOM_61 addEdge $L_E_S_E_4_12;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_61 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_61 setName LE_DOM_61

set L_E_S_E_1_13 [pw::Edge create];        $L_E_S_E_1_13 addConnector $RA_RC_3_12
set L_E_S_E_2_13 [pw::Edge create];        $L_E_S_E_2_13 addConnector $LINE_1_SPLIT_13
set L_E_S_E_3_13 [pw::Edge create];        $L_E_S_E_3_13 addConnector $CL6
set L_E_S_E_4_13 [pw::Edge create];        $L_E_S_E_4_13 addConnector $N_C_L_E_13
set DOM_62 [pw::DomainStructured create]
$DOM_62 addEdge $L_E_S_E_1_13;          $DOM_62 addEdge $L_E_S_E_2_13;
$DOM_62 addEdge $L_E_S_E_3_13;          $DOM_62 addEdge $L_E_S_E_4_13;                         
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_62 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_62 setName LE_DOM_62

$CREATE_A_STRUCTURE_DOMAIN_BETWEEN_ROODIDE_AND_TIPSIDE_AIRFOIL end

# CREATING DOMAIN OUTTER SURFACE OF CYLINDER
# S_E_O_S_O_S_PI = SELECT EDGE OUTLET SURFACE OF CYCLINDER PRESSURE INPUT

set CREATE_A_STRUCTURE_DOMAIN_OUTET_SURFACE_OF_CYLINDER [pw::Application begin Create]

set  S_E_O_S_O_C_PI_1 [pw::Edge create];    $S_E_O_S_O_C_PI_1 addConnector $CREATE_FIRST_122_DEGREE_CIRCLE
set S_E_O_S_O_C_PI_2 [pw::Edge create]
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_1; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_2
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_3; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_4
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_5; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_6
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_7; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_8
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_9; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_10
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_11; $S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_12
$S_E_O_S_O_C_PI_2 addConnector $LINE_2_SPLIT_13
set S_E_O_S_O_C_PI_3 [pw::Edge create];     $S_E_O_S_O_C_PI_3 addConnector $CREATE_FIRST_122_DEGREE_CIRCLE_TS
set S_E_O_S_O_C_PI_4 [pw::Edge create]
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_13; $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_12
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_11; $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_10
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_9;  $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_8
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_7;  $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_6
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_5;  $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_4
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_3;  $S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_2
$S_E_O_S_O_C_PI_4 addConnector $LINE_1_SPLIT_1
set DOM_63 [pw::DomainStructured create]
$DOM_63 addEdge $S_E_O_S_O_C_PI_1;          $DOM_63 addEdge $S_E_O_S_O_C_PI_2;
$DOM_63 addEdge $S_E_O_S_O_C_PI_3;          $DOM_63 addEdge $S_E_O_S_O_C_PI_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_63 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_63 setName OCS_DOM_63

set  S_E_O_S_O_C_PO_1 [pw::Edge create];  $S_E_O_S_O_C_PO_1 addConnector $CREATE_FIRST_179_DEGREE_CIRCLE
set S_E_O_S_O_C_PO_2 [pw::Edge create]
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_1;  $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_2
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_3;  $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_4
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_5;  $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_6
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_7;  $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_8
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_9;  $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_10
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_11; $S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_12
$S_E_O_S_O_C_PO_2 addConnector $LINE_3_SPLIT_13
set S_E_O_S_O_C_PO_3 [pw::Edge create];  $S_E_O_S_O_C_PO_3 addConnector $CREATE_FIRST_179_DEGREE_CIRCLE_TS
set S_E_O_S_O_C_PO_4 [pw::Edge create];
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_13;  $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_12
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_11;  $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_10
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_9;   $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_8
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_7;   $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_6
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_5;   $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_4
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_3;   $S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_2
$S_E_O_S_O_C_PO_4 addConnector $LINE_1_SPLIT_1
set DOM_64 [pw::DomainStructured create]
$DOM_64 addEdge $S_E_O_S_O_C_PO_1;          $DOM_64 addEdge $S_E_O_S_O_C_PO_2;
$DOM_64 addEdge $S_E_O_S_O_C_PO_3;          $DOM_64 addEdge $S_E_O_S_O_C_PO_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_64 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_64 setName OCS_DOM_64

set  S_E_O_S_O_C_T_1 [pw::Edge create];  $S_E_O_S_O_C_T_1 addConnector $CREATE_FIRST_59_DEGREE_CIRCLE

set S_E_O_S_O_C_T_2 [pw::Edge create]
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_1;  $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_2
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_3;  $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_4
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_5;  $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_6
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_7;  $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_8
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_9;  $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_10
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_11; $S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_12
$S_E_O_S_O_C_T_2 addConnector $LINE_3_SPLIT_13
set S_E_O_S_O_C_T_3 [pw::Edge create];          $S_E_O_S_O_C_T_3 addConnector $CREATE_FIRST_59_DEGREE_CIRCLE_TS
set S_E_O_S_O_C_T_4 [pw::Edge create]
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_13;  $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_12
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_11;  $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_10
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_9;   $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_8
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_7;   $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_6
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_5;   $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_4
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_3;   $S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_2
$S_E_O_S_O_C_T_4 addConnector $LINE_2_SPLIT_1
set DOM_65 [pw::DomainStructured create]
$DOM_65 addEdge $S_E_O_S_O_C_T_1;          $DOM_65 addEdge $S_E_O_S_O_C_T_2;
$DOM_65 addEdge $S_E_O_S_O_C_T_3;          $DOM_65 addEdge $S_E_O_S_O_C_T_4;                           
set CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_65 [pw::GridEntity getByName dom-1]
$CHANGE_A_NAME_OF_TRAILING_EGDGE_DOMAIN_65 setName OCS_DOM_65
$CREATE_A_STRUCTURE_DOMAIN_OUTET_SURFACE_OF_CYLINDER end

# ----------------------------------------------------------------------------------------------
# CREATE A CYLINDER BLOCK
# ----------------------------------------------------------------------------------------------

# pw:Application begin Create is used to create entities separate from existing entities
set block_1_179_DEGREE_CIRCLE [pw::Application begin Create]
# It's creating new blockstructured variable blk_1
set blk_1 [pw::BlockStructured create]
set selected_1_face [pw::FaceStructured create]; $selected_1_face addDomain $DOM_18; $blk_1 addFace $selected_1_face
set selected_2_face [pw::FaceStructured create]; $selected_2_face addDomain $DOM_15; $blk_1 addFace $selected_2_face
set selected_3_face [pw::FaceStructured create]
$selected_3_face addDomain $DOM_37; $selected_3_face addDomain $DOM_38
$selected_3_face addDomain $DOM_39; $selected_3_face addDomain $DOM_40
$selected_3_face addDomain $DOM_41; $selected_3_face addDomain $DOM_42
$selected_3_face addDomain $DOM_43; $selected_3_face addDomain $DOM_44
$selected_3_face addDomain $DOM_45; $selected_3_face addDomain $DOM_46
$selected_3_face addDomain $DOM_47; $selected_3_face addDomain $DOM_48
$selected_3_face addDomain $DOM_49
$blk_1 addFace $selected_3_face
set selected_4_face [pw::FaceStructured create]
$selected_4_face addDomain $DOM_50; $selected_4_face addDomain $DOM_51
$selected_4_face addDomain $DOM_52; $selected_4_face addDomain $DOM_53
$selected_4_face addDomain $DOM_54; $selected_4_face addDomain $DOM_55
$selected_4_face addDomain $DOM_56; $selected_4_face addDomain $DOM_57
$selected_4_face addDomain $DOM_58; $selected_4_face addDomain $DOM_59
$selected_4_face addDomain $DOM_60; $selected_4_face addDomain $DOM_61
$selected_4_face addDomain $DOM_62
$blk_1 addFace $selected_4_face
set selected_5_face [pw::FaceStructured create]; $selected_5_face addDomain $DOM_21; $blk_1 addFace $selected_5_face
set selected_6_face [pw::FaceStructured create]; $selected_6_face addDomain $DOM_64; $blk_1 addFace $selected_6_face
# close variables
$block_1_179_DEGREE_CIRCLE end

# pw:Application begin Create is used to create entities separate from existing entities
set block_2_122_DEGREE_CIRCLE [pw::Application begin Create]
# It's creating new blockstructured variable blk_1
set blk_2 [pw::BlockStructured create]
set selected_1_face_2 [pw::FaceStructured create]; $selected_1_face_2 addDomain $DOM_19; $blk_2 addFace $selected_1_face_2
set selected_2_face_2 [pw::FaceStructured create]; $selected_2_face_2 addDomain $DOM_14; $blk_2 addFace $selected_2_face_2
set selected_3_face_2 [pw::FaceStructured create]
$selected_3_face_2 addDomain $DOM_24; $selected_3_face_2 addDomain $DOM_25
$selected_3_face_2 addDomain $DOM_26; $selected_3_face_2 addDomain $DOM_27
$selected_3_face_2 addDomain $DOM_28; $selected_3_face_2 addDomain $DOM_29
$selected_3_face_2 addDomain $DOM_30; $selected_3_face_2 addDomain $DOM_31
$selected_3_face_2 addDomain $DOM_32; $selected_3_face_2 addDomain $DOM_33
$selected_3_face_2 addDomain $DOM_34; $selected_3_face_2 addDomain $DOM_35
$selected_3_face_2 addDomain $DOM_36
$blk_2 addFace $selected_3_face_2
set selected_4_face_2 [pw::FaceStructured create]
$selected_4_face_2 addDomain $DOM_50; $selected_4_face_2 addDomain $DOM_51
$selected_4_face_2 addDomain $DOM_52; $selected_4_face_2 addDomain $DOM_53
$selected_4_face_2 addDomain $DOM_54; $selected_4_face_2 addDomain $DOM_55
$selected_4_face_2 addDomain $DOM_56; $selected_4_face_2 addDomain $DOM_57
$selected_4_face_2 addDomain $DOM_58; $selected_4_face_2 addDomain $DOM_59
$selected_4_face_2 addDomain $DOM_60; $selected_4_face_2 addDomain $DOM_61
$selected_4_face_2 addDomain $DOM_62
$blk_2 addFace $selected_4_face_2
set selected_5_face_2 [pw::FaceStructured create]; $selected_5_face_2 addDomain $DOM_63; $blk_2 addFace $selected_5_face_2
set selected_6_face_2 [pw::FaceStructured create]; $selected_6_face_2 addDomain $DOM_22; $blk_2 addFace $selected_6_face_2
# close variables
$block_2_122_DEGREE_CIRCLE end

# pw:Application begin Create is used to create entities separate from existing entities
set block_3_59_DEGREE_CIRCLE [pw::Application begin Create]
# It's creating new blockstructured variable blk_1
set blk_3 [pw::BlockStructured create]
set selected_1_face_3 [pw::FaceStructured create]; $selected_1_face_3 addDomain $DOM_20; $blk_3 addFace $selected_1_face_3
set selected_2_face_3 [pw::FaceStructured create]
$selected_2_face_3 addDomain $DOM_24; $selected_2_face_3 addDomain $DOM_25
$selected_2_face_3 addDomain $DOM_26; $selected_2_face_3 addDomain $DOM_27
$selected_2_face_3 addDomain $DOM_28; $selected_2_face_3 addDomain $DOM_29
$selected_2_face_3 addDomain $DOM_30; $selected_2_face_3 addDomain $DOM_31
$selected_2_face_3 addDomain $DOM_32; $selected_2_face_3 addDomain $DOM_33
$selected_2_face_3 addDomain $DOM_34; $selected_2_face_3 addDomain $DOM_35
$selected_2_face_3 addDomain $DOM_36
$blk_3 addFace $selected_2_face_3
set selected_3_face_3 [pw::FaceStructured create]
$selected_3_face_3 addDomain $DOM_1; $selected_3_face_3 addDomain $DOM_2
$selected_3_face_3 addDomain $DOM_3; $selected_3_face_3 addDomain $DOM_4
$selected_3_face_3 addDomain $DOM_5; $selected_3_face_3 addDomain $DOM_6
$selected_3_face_3 addDomain $DOM_7; $selected_3_face_3 addDomain $DOM_8
$selected_3_face_3 addDomain $DOM_9; $selected_3_face_3 addDomain $DOM_10
$selected_3_face_3 addDomain $DOM_11;$selected_3_face_3 addDomain $DOM_12
$selected_3_face_3 addDomain $DOM_13
$blk_3 addFace $selected_3_face_3
set selected_4_face_3 [pw::FaceStructured create]
$selected_4_face_3 addDomain $DOM_37; $selected_4_face_3 addDomain $DOM_38;
$selected_4_face_3 addDomain $DOM_39; $selected_4_face_3 addDomain $DOM_40
$selected_4_face_3 addDomain $DOM_41; $selected_4_face_3 addDomain $DOM_42
$selected_4_face_3 addDomain $DOM_43; $selected_4_face_3 addDomain $DOM_44
$selected_4_face_3 addDomain $DOM_45; $selected_4_face_3 addDomain $DOM_46
$selected_4_face_3 addDomain $DOM_47; $selected_4_face_3 addDomain $DOM_48
$selected_4_face_3 addDomain $DOM_49
$blk_3 addFace $selected_4_face_3
set selected_5_face_3 [pw::FaceStructured create]; $selected_5_face_3 addDomain $DOM_65; $blk_3 addFace $selected_5_face_3
set selected_6_face_3 [pw::FaceStructured create]; $selected_6_face_3 addDomain $DOM_23; $blk_3 addFace $selected_6_face_3
# close variables
$block_3_59_DEGREE_CIRCLE end

# ----------------------------------------------------------------------------------------------
# Solve domain
# ----------------------------------------------------------------------------------------------
set SOLVE_DOMAIN_19_20 [pw::Application begin EllipticSolver [list $DOM_19 $DOM_20]]
$SOLVE_DOMAIN_19_20 setActiveSubGrids $DOM_19 [list]
$SOLVE_DOMAIN_19_20 setActiveSubGrids $DOM_20 [list]
$SOLVE_DOMAIN_19_20 run 100
$SOLVE_DOMAIN_19_20 end

# ----------------------------------------------------------------------------------------------
# Solve block
# ----------------------------------------------------------------------------------------------

set SOLVE_BLOCK_3 [pw::Application begin EllipticSolver [list $blk_3]]
$SOLVE_DOMAIN_19_20 setActiveSubGrids $blk_3 [list]
$SOLVE_DOMAIN_19_20 run 20
$SOLVE_DOMAIN_19_20 end

set SOLVE_BLOCK_3 [pw::Application begin EllipticSolver [list $blk_3]]
$SOLVE_DOMAIN_19_20 setActiveSubGrids $blk_3 [list]
$SOLVE_DOMAIN_19_20 run 20
$SOLVE_DOMAIN_19_20 end

###################################################################################################
# END SCRIPT OF STRUCTURE CYLINDER AROUND WIND TURBINE BLADE 
###################################################################################################

##################################################################################
##################################################################################
#  CREATE 120 DEFREE SEGMENT BLOCK
##################################################################################
##################################################################################

# -----------------------------------------------------------------------------------------------------------------
#                                          Create a line for 120 segment 
#------------------------------------------------------------------------------------------------------------------
# pw:Application begin Create is used to create entities separate from existing entities
set P_196 [pw::Application begin Create]
# This action creates a new connector spline segment object
set seg_196 [pw::SegmentSpline create];                  set seg_296 [pw::SegmentSpline create]
# Add a point(-3860.8189, 1136.3261, 119185.96) to the seg_206
$seg_196 addPoint "-$downwind_distance [expr 1.732 * $z3] $z3"
$seg_196 addPoint "-$downwind_distance [expr -1.732 * $z3] $z3"
$seg_296 addPoint "$upwind_distance [expr 1.732 * $z3] $z3"
$seg_296 addPoint "$upwind_distance [expr -1.732 * $z3] $z3"
# It creates a new connector object, name is line_206
set line_196 [pw::Connector create];                     set line_296 [pw::Connector create]
# seg_206 variable add in line_206 variable
$line_196 addSegment $seg_196;                           $line_296 addSegment $seg_296
$line_196 setDimension [expr "$NUMBER_OF_CONNECTORS/3"];    $line_296 setDimension [expr "$NUMBER_OF_CONNECTORS/3"]
$P_196 end
# -----------------------------------------------------------------------------------------------------------------
#                        Leadingedge outersurface axies co-ordinate values (x,y,z) & create a lines
# -----------------------------------------------------------------------------------------------------------------
# pw:Application begin Create is used to create entities separate from existing entities
set P331_5 [pw::Application begin Create]
# This action creates a new connector spline segment object
set seg331_5_1 [pw::SegmentSpline create];               set seg331_5_1_S2 [pw::SegmentSpline create];
set seg331_5_2 [pw::SegmentSpline create];               set seg331_5_2_S2 [pw::SegmentSpline create];
# Add a point to the seg
$seg331_5_1 addPoint "-$downwind_distance [expr 1.732 * $z3] $z3"
$seg331_5_2 addPoint "-$downwind_distance [expr -1.732 * $z3] $z3"
$seg331_5_1_S2 addPoint "$upwind_distance [expr 1.732 * $z3] $z3"
$seg331_5_2_S2 addPoint "$upwind_distance [expr -1.732 * $z3] $z3"
# Add a point to the seg331_5_1
$seg331_5_1 addPoint "-$downwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$seg331_5_2 addPoint "-$downwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
$seg331_5_1_S2 addPoint "$upwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$seg331_5_2_S2 addPoint "$upwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
# It creates a new connector object
set line203 [pw::Connector create];                     set line205 [pw::Connector create];
set line204 [pw::Connector create];                     set line206 [pw::Connector create];
# seg variable add in line variable
$line203 addSegment $seg331_5_1;                        $line205 addSegment $seg331_5_1_S2;
$line204 addSegment $seg331_5_2;                        $line206 addSegment $seg331_5_2_S2;
$line203 setDimension [expr "4*$NUMBER_OF_CONNECTORS"];     $line205 setDimension [expr "4*$NUMBER_OF_CONNECTORS"];
$line204 setDimension [expr "4*$NUMBER_OF_CONNECTORS"];     $line206 setDimension [expr "4*$NUMBER_OF_CONNECTORS"];
$P331_5 end
# -----------------------------------------------------------------------------------------------------------------
#                                
# -----------------------------------------------------------------------------------------------------------------
set circle_120_degree [pw::Application begin Create]
set circle_120_degree_lowerside_1 [pw::SegmentCircle create]
set circle_120_degree_lowerside_2 [pw::SegmentCircle create]
$circle_120_degree_lowerside_1 addPoint "-$downwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$circle_120_degree_lowerside_1 addPoint "-$downwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
$circle_120_degree_lowerside_2 addPoint "$upwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$circle_120_degree_lowerside_2 addPoint "$upwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
$circle_120_degree_lowerside_1 setAngle 120 {0 1 0}
$circle_120_degree_lowerside_2 setAngle 120 {0 1 0}
set circle_331_1 [pw::Connector create]
set circle_331_2 [pw::Connector create]
$circle_331_1 addSegment $circle_120_degree_lowerside_1
$circle_331_2 addSegment $circle_120_degree_lowerside_2
$circle_331_1 setDimension [expr "7*$NUMBER_OF_CONNECTORS"]
$circle_331_2  setDimension [expr "7*$NUMBER_OF_CONNECTORS"]
$circle_120_degree end
# -----------------------------------------------------------------------------------------------------------------
#                                 Creating line 120 degree segment
# -----------------------------------------------------------------------------------------------------------------

# pw:Application begin Create is used to create entities separate from existing entities
set SG120 [pw::Application begin Create]
# This action creates a new connector spline segment object
set SG1 [pw::SegmentSpline create];                         set SG2 [pw::SegmentSpline create];
set SG3 [pw::SegmentSpline create];                         set SG4 [pw::SegmentSpline create];
# it is represented of co-ordinate value of axises
$SG1 addPoint "-$downwind_distance [expr 1.732 * $z3] $z3"
$SG1 addPoint "$upwind_distance [expr 1.732 * $z3] $z3"
$SG2 addPoint "-$downwind_distance [expr -1.732 * $z3] $z3"
$SG2 addPoint "$upwind_distance [expr -1.732 * $z3] $z3"
$SG3 addPoint "-$downwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$SG3 addPoint "$upwind_distance [expr 1.732 * 80 * $z3] [expr 80 * $z3]"
$SG4 addPoint "-$downwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
$SG4 addPoint "$upwind_distance [expr -1.732 * 80 * $z3] [expr 80 * $z3]"
# It creates a new connector object
set line207 [pw::Connector create];                        set line208 [pw::Connector create];
set line209 [pw::Connector create];                        set line210 [pw::Connector create];
# US331 - US338 variables add in line18 - line25 variable
$line207 addSegment $SG1;                                  $line208 addSegment $SG2;
$line209 addSegment $SG3;                                  $line210 addSegment $SG4;
$line207  setDimension [expr "5*$NUMBER_OF_CONNECTORS"];
$line208  setDimension [expr "5*$NUMBER_OF_CONNECTORS"];
$line209  setDimension [expr "5*$NUMBER_OF_CONNECTORS"];
$line210  setDimension [expr "5*$NUMBER_OF_CONNECTORS"];
$SG120 end
# -----------------------------------------------------------------------------------------------------------------
# Create a domain
# -----------------------------------------------------------------------------------------------------------------
set domain_66 [pw::Application begin Create]
set face_66 [pw::Edge create]
$face_66 addConnector $line_196;  $face_66 addConnector $line207
$face_66 addConnector $line_296;  $face_66 addConnector $line208
set dom_66 [pw::DomainUnstructured create]
$dom_66 addEdge $face_66
$dom_66 setName WTD_DOM_66
$domain_66 end

set domain_67_68 [pw::Application begin Create];
set face_67 [pw::Edge create];                                 set face_68 [pw::Edge create];
$face_67 addConnector $line203;                                $face_68 addConnector $line204;
$face_67 addConnector $line207;                                $face_68 addConnector $line208;
$face_67 addConnector $line205;                                $face_68 addConnector $line206;
$face_67 addConnector $line209;                                $face_68 addConnector $line210;
set dom_67 [pw::DomainUnstructured create];                     set dom_68 [pw::DomainUnstructured create];
$dom_67 addEdge $face_67;                                      $dom_68 addEdge $face_68;
$dom_67 setName WTD_DOM_67;                                    $dom_68 setName WTD_DOM_68;
$domain_67_68 end; 

set domain_69_70 [pw::Application begin Create];
set face_69 [pw::Edge create];                                 set face_70 [pw::Edge create];
$face_69 addConnector $line_196;                               $face_70 addConnector $line_296;
$face_69 addConnector $line203;                                $face_70 addConnector $line205;
$face_69 addConnector $circle_331_1;                           $face_70 addConnector $circle_331_2;
$face_69 addConnector $line204;                                $face_70 addConnector $line206;
set dom_69 [pw::DomainUnstructured create];                     set dom_70 [pw::DomainUnstructured create];
$dom_69 addEdge $face_69;                                      $dom_70 addEdge $face_70;
$dom_69 setName 120_UPWIND_DOM_69;  $dom_70 setName 120_DOWNWIND_DOM_70
$domain_69_70 end;    

set domain_71 [pw::Application begin Create]
set face_71 [pw::Edge create]
$face_71 addConnector $circle_331_1
$face_71 addConnector $line209
$face_71 addConnector $circle_331_2
$face_71 addConnector $line210
set dom_71 [pw::DomainUnstructured create]
$dom_71 addEdge $face_71
$dom_71 setName 120_SC_DOM_71; 
$domain_71 end
# ----------------------------------------------------------------------------------------------
# Create block
# ----------------------------------------------------------------------------------------------
set block_4 [pw::Application begin Create]
set blk_4 [pw::BlockUnstructured create]
set selected_face_4_1 [pw::FaceUnstructured create]
$selected_face_4_1 addDomain $dom_69;   $selected_face_4_1 addDomain $dom_68; 
$selected_face_4_1 addDomain $dom_66;   $selected_face_4_1 addDomain $dom_67; 
$selected_face_4_1 addDomain $dom_71;   $selected_face_4_1 addDomain $dom_70
$blk_4 addFace $selected_face_4_1
set selected_face_4_2 [pw::FaceUnstructured create]
$selected_face_4_2 addDomain $dom_17;   $selected_face_4_2 addDomain $DOM_23
$selected_face_4_2 addDomain $DOM_22;    $selected_face_4_2 addDomain $DOM_21
$selected_face_4_2 addDomain $DOM_64;    $selected_face_4_2 addDomain $DOM_65
$selected_face_4_2 addDomain $DOM_63;    $selected_face_4_2 addDomain $DOM_18
$selected_face_4_2 addDomain $DOM_19;    $selected_face_4_2 addDomain $DOM_20
$selected_face_4_2 addDomain $dom_16;   
$blk_4 addFace $selected_face_4_2 
$block_4 end

destroy .
}

############################################################################################################

############################################################################################################
# Function to update parameters and run the original process
proc updateParameters {} {
    # Access global variables within this procedure
    global NUMBER_OF_CONNECTORS SPACING_CONSTRAINT_VALUE CYLINDER_RADIUS y1 z1 z2 x1 z3 upwind_distance downwind_distance
    # Update parameter values from GUI entry widgets
    set NUMBER_OF_CONNECTORS [.mainFrame.entry1 get]
    set SPACING_CONSTRAINT_VALUE [.mainFrame.entry2 get]
    set CYLINDER_RADIUS [.mainFrame.entry3 get]
    set y1 [.mainFrame.entry4 get]
    set z1 [.mainFrame.entry5 get]
    set z2 [.mainFrame.entry6 get]
    set x1 [.mainFrame.entry7 get]
    set z3 [.mainFrame.entry8 get]
    set upwind_distance [.mainFrame.entry9 get]
    set downwind_distance [.mainFrame.entry10 get]
    
    # Call your original process with updated parameters
    runOriginalProcess
}

############################################################################################################

############################################################################################################

# Build the Tk interface
proc makeWindow { } {
  # Create main GUI window
  wm title . "Parameter Settings"
  wm geometry . 400x500

  # Create a frame to hold parameter input elements
  frame .mainFrame

  # Label and entry widgets for each parameter
  label .mainFrame.label1 -text "Number of Connectors:"
  entry .mainFrame.entry1 -textvariable NUMBER_OF_CONNECTORS
  label .mainFrame.label2 -text "Spacing Constraint Value:"
  entry .mainFrame.entry2 -textvariable SPACING_CONSTRAINT_VALUE
  label .mainFrame.label3 -text "Cylinder Radius:"
  entry .mainFrame.entry3 -textvariable CYLINDER_RADIUS
  label .mainFrame.label4 -text "move the cylinder in the y-direction (y1):"
  entry .mainFrame.entry4 -textvariable y1
  label .mainFrame.label5 -text "z1:"
  entry .mainFrame.entry5 -textvariable z1
  label .mainFrame.label6 -text "z2:"
  entry .mainFrame.entry6 -textvariable z2
  label .mainFrame.label7 -text "move the cylinder in the x-direction (x1):"
  entry .mainFrame.entry7 -textvariable x1
  label .mainFrame.label8 -text "change the value of 120 degree of block (z3):"
  entry .mainFrame.entry8 -textvariable z3
  label .mainFrame.label9 -text "upwind_distance:"
  entry .mainFrame.entry9 -textvariable upwind_distance
  label .mainFrame.label10 -text "downwind_distance:"
  entry .mainFrame.entry10 -textvariable downwind_distance

  # Button to update parameters
  button .mainFrame.updateButton -text "Update Parameters" -command updateParameters

  # Grid layout for the elements
  grid .mainFrame.label1 .mainFrame.entry1
  grid .mainFrame.label2 .mainFrame.entry2
  grid .mainFrame.label3 .mainFrame.entry3
  grid .mainFrame.label4 .mainFrame.entry4
  grid .mainFrame.label5 .mainFrame.entry5
  grid .mainFrame.label6 .mainFrame.entry6
  grid .mainFrame.label7 .mainFrame.entry7
  grid .mainFrame.label8 .mainFrame.entry8
  grid .mainFrame.label9 .mainFrame.entry9
  grid .mainFrame.label10 .mainFrame.entry10
  grid .mainFrame.updateButton

  # Pack the frame
  pack .mainFrame

}

#######################################################################################################

# create the Tk window and place it
makeWindow

# process Tk events until the window is destroyed
tkwait window .





 






















