#!/usr/bin/env python3
import os
import sys

def check_em_dash(file_path):
    issues = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if '—' in line:
                    issues.append(f"{file_path}:{i+1} Contains em dash '—'. Use plain dash '-' instead.")
    except Exception as e:
        pass # skip binary files or unreadable files
    return issues

def check_javax_servlet(file_path):
    issues = []
    if file_path.endswith('.java'):
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                for i, line in enumerate(f):
                    if 'javax.servlet' in line:
                        issues.append(f"{file_path}:{i+1} Uses 'javax.servlet'. Use 'jakarta.servlet' instead.")
        except Exception:
            pass
    return issues

def check_html_views(file_path):
    issues = []
    if file_path.endswith('.html'):
        issues.append(f"{file_path}: HTML view found. Views should be JSP (.jsp).")
    return issues

def main():
    has_errors = False
    
    src_dir = 'src'
    webapp_dir = os.path.join('src', 'main', 'webapp')
    
    # Check 1: No HTML views in webapp
    if os.path.exists(webapp_dir):
        for root, _, files in os.walk(webapp_dir):
            for file in files:
                file_path = os.path.join(root, file)
                issues = check_html_views(file_path)
                for issue in issues:
                    print(f"[ERROR] {issue}")
                    has_errors = True
                    
    # Check 2: No javax.servlet in java files, and no em dash in source files
    if os.path.exists(src_dir):
        for root, _, files in os.walk(src_dir):
            for file in files:
                file_path = os.path.join(root, file)
                
                # Check javax.servlet
                javax_issues = check_javax_servlet(file_path)
                for issue in javax_issues:
                    print(f"[ERROR] {issue}")
                    has_errors = True
                    
                # Check em dash (only in text source files like java, jsp, css, js, xml)
                if file.endswith(('.java', '.jsp', '.css', '.js', '.xml')):
                    em_dash_issues = check_em_dash(file_path)
                    for issue in em_dash_issues:
                        print(f"[ERROR] {issue}")
                        has_errors = True
                        
    # Check pom.xml for em dash
    if os.path.exists('pom.xml'):
        em_dash_issues = check_em_dash('pom.xml')
        for issue in em_dash_issues:
            print(f"[ERROR] {issue}")
            has_errors = True

    if has_errors:
        print("\nProject preferences check FAILED.")
        sys.exit(1)
    else:
        print("Project preferences check PASSED.")
        sys.exit(0)

if __name__ == '__main__':
    main()
