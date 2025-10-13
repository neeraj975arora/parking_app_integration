#!/usr/bin/env python3
"""
Test Runner for Smart Parking Backend
====================================

This script provides a comprehensive test runner for the Smart Parking Backend
with support for different test categories and configurations.
"""

import os
import sys
import argparse
import subprocess
from pathlib import Path


def run_command(command, description=""):
    """Run a command and return the result."""
    print(f"\n{'='*60}")
    print(f"Running: {description or command}")
    print(f"{'='*60}")
    
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}")
        print("STDOUT:", e.stdout)
        print("STDERR:", e.stderr)
        return False


def setup_environment():
    """Setup the test environment."""
    print("Setting up test environment...")
    
    # Set environment variables
    os.environ['FLASK_ENV'] = 'testing'
    os.environ['DATABASE_URL'] = 'sqlite:///test.db'
    os.environ['JWT_SECRET_KEY'] = 'test-secret-key'
    os.environ['RPI_API_KEY'] = 'test-api-key'
    
    print("Environment variables set:")
    print(f"  FLASK_ENV: {os.environ.get('FLASK_ENV')}")
    print(f"  DATABASE_URL: {os.environ.get('DATABASE_URL')}")
    print(f"  JWT_SECRET_KEY: {os.environ.get('JWT_SECRET_KEY')}")
    print(f"  RPI_API_KEY: {os.environ.get('RPI_API_KEY')}")


def run_unit_tests(verbose=False, coverage=False):
    """Run unit tests."""
    cmd = "pytest tests/test_auth.py tests/test_parking.py tests/test_admin_api.py"
    
    if verbose:
        cmd += " -v"
    
    if coverage:
        cmd += " --cov=app --cov-report=html --cov-report=xml --cov-report=term"
    
    cmd += " --tb=short"
    
    return run_command(cmd, "Unit Tests")


def run_integration_tests(verbose=False, coverage=False):
    """Run integration tests."""
    cmd = "pytest tests/test_integration.py"
    
    if verbose:
        cmd += " -v"
    
    if coverage:
        cmd += " --cov=app --cov-report=html --cov-report=xml --cov-report=term"
    
    cmd += " --tb=short -m integration"
    
    return run_command(cmd, "Integration Tests")


def run_security_tests(verbose=False):
    """Run security tests."""
    cmd = "pytest tests/test_security.py"
    
    if verbose:
        cmd += " -v"
    
    cmd += " --tb=short -m security"
    
    return run_command(cmd, "Security Tests")


def run_all_tests(verbose=False, coverage=False):
    """Run all tests."""
    cmd = "pytest tests/"
    
    if verbose:
        cmd += " -v"
    
    if coverage:
        cmd += " --cov=app --cov-report=html --cov-report=xml --cov-report=term"
    
    cmd += " --tb=short"
    
    return run_command(cmd, "All Tests")


def run_specific_test(test_path, verbose=False):
    """Run a specific test file or function."""
    cmd = f"pytest {test_path}"
    
    if verbose:
        cmd += " -v"
    
    cmd += " --tb=short"
    
    return run_command(cmd, f"Specific Test: {test_path}")


def run_performance_tests(verbose=False):
    """Run performance tests."""
    cmd = "pytest tests/test_integration.py::TestPerformanceAndLoad"
    
    if verbose:
        cmd += " -v"
    
    cmd += " --tb=short --benchmark-only"
    
    return run_command(cmd, "Performance Tests")


def run_linting():
    """Run code linting."""
    commands = [
        ("flake8 app/ tests/ --count --select=E9,F63,F7,F82 --show-source --statistics", "Flake8 Critical Issues"),
        ("flake8 app/ tests/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics", "Flake8 All Issues"),
        ("black --check --diff app/ tests/", "Black Code Formatting"),
        ("isort --check-only --diff app/ tests/", "Import Sorting")
    ]
    
    results = []
    for cmd, desc in commands:
        results.append(run_command(cmd, desc))
    
    return all(results)


def run_type_checking():
    """Run type checking."""
    return run_command("mypy app/ --ignore-missing-imports", "Type Checking")


def generate_test_report():
    """Generate a comprehensive test report."""
    print("\n" + "="*60)
    print("GENERATING TEST REPORT")
    print("="*60)
    
    # Run tests with HTML report
    cmd = "pytest tests/ --html=test_report.html --self-contained-html --cov=app --cov-report=html"
    success = run_command(cmd, "Generating Test Report")
    
    if success:
        print("\nTest report generated: test_report.html")
        print("Coverage report generated: htmlcov/index.html")
    
    return success


def main():
    """Main test runner function."""
    parser = argparse.ArgumentParser(description='Smart Parking Backend Test Runner')
    parser.add_argument('--type', choices=['unit', 'integration', 'security', 'all', 'specific', 'performance'], 
                       default='all', help='Type of tests to run')
    parser.add_argument('--test', help='Specific test file or function to run')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--coverage', '-c', action='store_true', help='Generate coverage report')
    parser.add_argument('--lint', action='store_true', help='Run linting checks')
    parser.add_argument('--type-check', action='store_true', help='Run type checking')
    parser.add_argument('--report', action='store_true', help='Generate test report')
    parser.add_argument('--setup', action='store_true', help='Setup test environment only')
    
    args = parser.parse_args()
    
    # Change to the Backend directory
    backend_dir = Path(__file__).parent
    os.chdir(backend_dir)
    
    print("Smart Parking Backend Test Runner")
    print("="*40)
    
    # Setup environment
    setup_environment()
    
    if args.setup:
        print("Test environment setup complete.")
        return 0
    
    success = True
    
    # Run linting if requested
    if args.lint:
        success &= run_linting()
    
    # Run type checking if requested
    if args.type_check:
        success &= run_type_checking()
    
    # Run tests based on type
    if args.type == 'unit':
        success &= run_unit_tests(args.verbose, args.coverage)
    elif args.type == 'integration':
        success &= run_integration_tests(args.verbose, args.coverage)
    elif args.type == 'security':
        success &= run_security_tests(args.verbose)
    elif args.type == 'performance':
        success &= run_performance_tests(args.verbose)
    elif args.type == 'specific':
        if not args.test:
            print("Error: --test argument required for specific test type")
            return 1
        success &= run_specific_test(args.test, args.verbose)
    elif args.type == 'all':
        success &= run_all_tests(args.verbose, args.coverage)
    
    # Generate report if requested
    if args.report:
        success &= generate_test_report()
    
    # Print summary
    print("\n" + "="*60)
    if success:
        print("✅ ALL TESTS PASSED")
    else:
        print("❌ SOME TESTS FAILED")
    print("="*60)
    
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
