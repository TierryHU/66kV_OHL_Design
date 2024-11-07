# 66kV_OHL_Design

This repository contains MATLAB code and documentation for the design and analysis of a 66kV overhead transmission line. The project focuses on calculating the required clearances, power ratings, conductor and insulator specifications, and structural considerations necessary for a reliable and safe transmission line under specific environmental and mechanical conditions.

Project Overview

Overhead transmission line design requires careful analysis of electrical and mechanical parameters to ensure the line can withstand various environmental factors such as wind load, temperature changes, and conductor sag. This project includes functions and scripts that:

Determine phase-to-phase and phase-to-ground clearances.

Calculate the maximum permissible wind load on conductors.

Evaluate conductor sag at different temperatures.

Assess insulator requirements based on voltage and environmental conditions.

Repository Structure

Insulator.m: This script calculates insulator specifications, including required creepage distance, length, and mechanical strength for both U160BS and S248130V5 types or some insulator else..

P_50kmMax_Wind.m: Determines the conductor swing and displacement under maximum wind load conditions for a 50 km span.

P_Max_Wind.m: Calculates the maximum conductor displacement and swing angle due to wind at varying intensities, providing necessary inputs for clearance calculations.

U50.m: Computes the minimum safe clearances based on dielectric strength calculations, including AC voltage, lightning impulse, and switching impulse withstand levels, to ensure compliance with voltage and clearance standards.
