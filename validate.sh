#!/bin/bash

# SURGICALSIM Project Validation Script
# This script validates the project structure and checks for common issues

echo "=========================================="
echo "SURGICALSIM Project Validation"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "project.godot" ]; then
    echo "ERROR: project.godot not found. Please run this script from the SURGICALSIM directory."
    exit 1
fi

echo "✓ Found project.godot"

# Check required directories
echo ""
echo "Checking directory structure..."
required_dirs=("core" "patient" "surgery" "anatomy" "instruments" "interaction" "events" "evaluation" "ui" "scenes" "data")

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ Found directory: $dir"
    else
        echo "✗ Missing directory: $dir"
    fi
done

# Check required files
echo ""
echo "Checking required files..."
required_files=(
    "project.godot"
    "scenes/main.tscn"
    "core/event_bus.gd"
    "core/simulation_manager.gd"
    "core/camera_controller.gd"
    "patient/patient.gd"
    "patient/operating_table.gd"
    "anatomy/anatomical_object.gd"
    "anatomy/appendix.gd"
    "instruments/instrument.gd"
    "instruments/scalpel.gd"
    "interaction/interaction_manager.gd"
    "ui/hud.gd"
    "ui/simulation_controls.gd"
    "ui/results_screen.gd"
    "data/surgeries/appendicectomy.json"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found file: $file"
    else
        echo "✗ Missing file: $file"
    fi
done

# Check for GDScript syntax issues (basic check)
echo ""
echo "Checking GDScript files for basic syntax..."
gd_files=$(find . -name "*.gd" -type f)

for file in $gd_files; do
    if grep -q "^extends " "$file"; then
        echo "✓ $file has proper extends declaration"
    else
        echo "✗ $file missing extends declaration"
    fi
    
    if grep -q "func " "$file"; then
        echo "✓ $file has function definitions"
    else
        echo "✗ $file has no function definitions"
    fi
done

# Check scene file structure
echo ""
echo "Checking scene file structure..."
if grep -q "\[gd_scene" scenes/main.tscn; then
    echo "✓ main.tscn is a valid Godot scene file"
else
    echo "✗ main.tscn is not a valid Godot scene file"
fi

if grep -q "script" scenes/main.tscn; then
    echo "✓ main.tscn contains script references"
else
    echo "✗ main.tscn missing script references"
fi

# Check autoload configuration
echo ""
echo "Checking autoload configuration..."
if grep -q "Events=" project.godot; then
    echo "✓ Events autoload configured"
else
    echo "✗ Events autoload not configured"
fi

if grep -q "SimulationManager=" project.godot; then
    echo "✓ SimulationManager autoload configured"
else
    echo "✗ SimulationManager autoload not configured"
fi

# Check input configuration
echo ""
echo "Checking input configuration..."
if grep -q "touch_camera=" project.godot; then
    echo "✓ Touch camera input configured"
else
    echo "✗ Touch camera input not configured"
fi

if grep -q "pinch_zoom=" project.godot; then
    echo "✓ Pinch zoom input configured"
else
    echo "✗ Pinch zoom input not configured"
fi

# Check data files
echo ""
echo "Checking data files..."
if [ -f "data/surgeries/appendicectomy.json" ]; then
    if python3 -m json.tool "data/surgeries/appendicectomy.json" > /dev/null 2>&1; then
        echo "✓ appendicectomy.json is valid JSON"
    else
        echo "✗ appendicectomy.json is not valid JSON"
    fi
fi

echo ""
echo "=========================================="
echo "Validation Complete"
echo "=========================================="
echo ""
echo "Project Structure Summary:"
echo "- Total files: $(find . -type f | wc -l)"
echo "- GDScript files: $(find . -name "*.gd" | wc -l)"
echo "- Scene files: $(find . -name "*.tscn" | wc -l)"
echo "- Data files: $(find . -name "*.json" | wc -l)"
echo ""
echo "Next Steps:"
echo "1. Open project in Godot 4.x editor"
echo "2. Check for any import errors"
echo "3. Test on Android device"
echo "4. Verify touch controls work"
