#!/usr/bin/env bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED_TESTS=0
TOTAL_TESTS=0
SCORE=0

log_result() {
    local test_name="$1"
    local status="$2"
    local points="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ "$status" -eq 0 ]; then
        echo -e "[${GREEN}PASS${NC}] $test_name (+$points pts)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        SCORE=$((SCORE + points))
    else
        echo -e "[${RED}FAIL${NC}] $test_name (0 pts)"
    fi
}

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

echo -e "${YELLOW}=== Starting tumls Automated Evaluation ===${NC}\n"

# -----------------------------------------------------------------------------
# Test 1: Compilation Check
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1] Testing Compilation${NC}"
if [ -f "Makefile" ]; then
    make clean >/dev/null 2>&1
fi

gcc -o tumls tumls.c -Wall -Werror > "$TEST_DIR/compile.log" 2>&1
if [ $? -eq 0 ] && [ -x "tumls" ]; then
    log_result "Clean compilation (-Wall -Werror)" 0 15
else
    log_result "Clean compilation (-Wall -Werror)" 1 15
    echo -e "${RED}Aborting further tests due to compilation failure.${NC}"
    exit 1
fi
echo ""

# Setup test directory structure
SUB_DIR="$TEST_DIR/nested_dir"
mkdir -p "$SUB_DIR"
touch "$SUB_DIR/file1.txt"
chmod 755 "$SUB_DIR/file1.txt"
touch "$SUB_DIR/file2.bin"
chmod 600 "$SUB_DIR/file2.bin"

# -----------------------------------------------------------------------------
# Test 2: No Arguments (Current Directory)
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2] Testing No Arguments Mode${NC}"
./tumls > "$TEST_DIR/stdout_noargs.txt" 2>/dev/null
if [ $? -eq 0 ] && grep -q "tumls" "$TEST_DIR/stdout_noargs.txt"; then
    log_result "Current directory listing executed successfully" 0 20
else
    log_result "Current directory listing executed successfully" 1 20
fi

# -----------------------------------------------------------------------------
# Test 3: Path Argument & Path Concatenation Check
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3] Testing Directory Argument & Path Concatenation${NC}"
./tumls "$SUB_DIR" > "$TEST_DIR/stdout_arg.txt" 2>/dev/null
ARG_STATUS=$?

# Verify that nested files appear in the output
if [ $ARG_STATUS -eq 0 ] && grep -q "file1.txt" "$TEST_DIR/stdout_arg.txt" && grep -q "file2.bin" "$TEST_DIR/stdout_arg.txt"; then
    log_result "Nested directory path listing (Path Concatenation verified)" 0 25
else
    log_result "Nested directory path listing (Path Concatenation verified)" 1 25
fi

# -----------------------------------------------------------------------------
# Test 4: Permission & Type Output Verification
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[4] Testing Metadata Formatting (Type and Permissions)${NC}"
if grep -q "\[FILE\]" "$TEST_DIR/stdout_arg.txt" && grep -q "rwxr-xr-x" "$TEST_DIR/stdout_arg.txt"; then
    log_result "Metadata decoding ([FILE]/[DIR] tags and rwx permissions)" 0 20
else
    log_result "Metadata decoding ([FILE]/[DIR] tags and rwx permissions)" 1 20
fi

# -----------------------------------------------------------------------------
# Test 5: Error Handling
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[5] Testing Error Handling on Non-Existent Directory${NC}"
ERR_OUT=$(./tumls "$TEST_DIR/invalid_path" 2>&1 >/dev/null)
ERR_EXIT=$?

if [ $ERR_EXIT -eq 1 ] && [ "$ERR_OUT" == "tumls: cannot open directory" ]; then
    log_result "Exact error message and exit status 1" 0 20
else
    echo -e "   ${RED}Received Output:${NC} '$ERR_OUT' (Exit Code: $ERR_EXIT)"
    log_result "Exact error message and exit status 1" 1 20
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}=== Automated Test Summary ===${NC}"
echo -e "Tests Passed: $PASSED_TESTS / $TOTAL_TESTS"
echo -e "Automated Score: ${GREEN}${SCORE} / 100${NC}\n"