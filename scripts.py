#!/usr/bin/env python3
import subprocess
import argparse
import platform
import os
from typing import List

DART_FRB = "lib/src/rust/frb_generated.dart"
DART_FRB_IO = "lib/src/rust/frb_generated.io.dart"
DART_FRB_WEB = "lib/src/rust/frb_generated.web.dart"
RUST_FRB_IO = "rust/src/frb_generated.io.rs"
RUST_FRB = "rust/src/frb_generated.rs"
RUST_FRB_WEB = "rust/src/frb_generated.web.rs"

FRB_FILES = [DART_FRB, DART_FRB_IO, DART_FRB_WEB, RUST_FRB_IO, RUST_FRB, RUST_FRB_WEB]

DMG_CONFIG = "packages/config.json"
OUTPUT_DMG = "packages/mdd.dmg"

FRB_INSTALL_NAME = "flutter_rust_bridge_codegen@^2.11.1"

IOS_PODS_FILES = "ios/Podfile ios/Podfile.lock ios/Pods/"
MACOS_PODS_FILES = "macos/Podfile macos/Podfile.lock macos/Pods/"


class Build:
    def __init__(self):
        pass

    def build_all(self) -> None:
        os_name: str = platform.system()
        print(f"Building for all platforms on {os_name}...")
        try:
            if platform.system() == "Windows":
                self.build_windows()
            elif platform.system() == "Darwin":
                self.build_android()
                self.build_ios()
                self.build_macos()
            elif platform.system() == "Linux":
                self.build_linux()
            else:
                print("Unsupported platform")

        except Exception as e:
            print(f"Error building project for all platforms: {str(e)}")

    def build_android(self) -> None:
        print("Building for Android...")
        try:
            self.build_bundle()
            self.build_apk()
            print("Project built successfully\n")
        except Exception as e:
            print("Error building project for android:", str(e))

    def build_apk(self) -> None:
        print("Building apk for Android...")
        try:
            subprocess.run(["flutter", "build", "apk", "--release", "--split-per-abi"])
            print("Project built successfully\n")
        except Exception as e:
            print("Error building project for android:", str(e))

    def build_bundle(self) -> None:
        print("Building appbundle for Android...")
        try:
            subprocess.run(["flutter", "build", "appbundle", "--release"])
            print("Project built successfully\n")
        except Exception as e:
            print("Error building project for android:", str(e))

    def build_ios(self) -> None:
        print("Building for iOS...")
        try:
            subprocess.run(["flutter", "build", "ios", "--release"])
            print("Project built successfully\n")
        except Exception as e:
            print("Error building project for ios:", str(e))

    def build_macos(self) -> None:
        print("Building for macOS...")
        try:
            subprocess.run(["flutter", "build", "macos", "--release"])
            print("Project built successfully\n")
            self._remove_dmg()
            self._create_dmg()
            self._open_dmg()
        except Exception as e:
            print("Error building project for macos:", str(e))

    def build_linux(self) -> None:
        print("Building for Linux...")
        try:
            subprocess.run(["flutter", "build", "linux", "--release"])
            print("Project built successfully\n")
        except Exception as e:
            print("Error building project for linux:", str(e))

    def build_windows(self) -> None:
        print("Building for Windows...")
        try:
            subprocess.run(["flutter", "build", "windows", "--release"], shell=True)
            print("Project built successfully\n")

        except Exception as e:
            print("Error building project for windows:", str(e))
            return

    def _create_dmg(self) -> None:
        print("Creating dmg...")
        try:
            subprocess.run(["appdmg", DMG_CONFIG, OUTPUT_DMG])
            print("Dmg created successfully\n")
        except Exception as e:
            print("Error creating dmg:", str(e))

    def _remove_dmg(self) -> None:
        print("Removing dmg...")
        try:
            if os.path.exists(OUTPUT_DMG):
                os.remove(OUTPUT_DMG)
                print("Dmg removed successfully\n")
        except OSError as e:
            print("Error removing dmg:", str(e))

    def _open_dmg(self) -> None:
        print("Opening dmg...")
        try:
            subprocess.run(["open", OUTPUT_DMG])
            print("Dmg opened successfully\n")
        except Exception as e:
            print("Error opening dmg:", str(e))


class BuildRust:
    def __init__(self):
        pass

    def install_frb_executable(self) -> None:
        print("Installing frb executable...")
        try:
            subprocess.run(["cargo", "install", FRB_INSTALL_NAME])
            print("Frb executable installed successfully\n")
        except Exception as e:
            print("Error installing frb executable:", str(e))
            return

    def generate_frb_code(self, is_clean: bool) -> None:
        print("Generating frb code...")
        try:
            if is_clean:
                self.remove_old_frb_code()
            subprocess.run(["flutter_rust_bridge_codegen", "generate"])
            print("Rust code generated successfully\n")
        except Exception as e:
            print("Error generating frb code:", str(e))
            return
        
    def clean_frb_files(self) -> None:
        print("Cleaning frb code...")
        try:
            self.remove_old_frb_code()
            subprocess.run(["rm", "-rf", "rust_builder"])
            subprocess.run(["rm", "-rf", "flutter_rust_bridge.yaml"])
            subprocess.run(["rm", "-rf", "integration_test"])
            print("Frb code cleaned successfully\n")
        except Exception as e:
            print("Error cleaning frb code:", str(e))
            return

    def update_frb_executable(self) -> None:
        print("Updating frb executable...")
        try:
            subprocess.run(["cargo", "install", FRB_INSTALL_NAME])
            self.update_rust_dependencies()
            print("Frb executable updated successfully\n")
        except Exception as e:
            print("Error updating frb executable:", str(e))
            return

    def remove_old_frb_code(self) -> None:
        print("Removing old frb code...")
        try:
            for file in FRB_FILES:
                if os.path.exists(file):
                    os.remove(file)
                    print(f"Removed {file}")
            print("Old frb code removed successfully\n")
        except Exception as e:
            print("Error removing old frb code:", str(e))
            return

    def check_rust_dependencies(self) -> None:
        print("Checking rust dependencies...")
        try:
            subprocess.run(["cargo", "check"], cwd="rust")
            print("Rust dependencies checked successfully\n")
        except Exception as e:
            print("Error checking rust dependencies:", str(e))
            return

    def update_rust_dependencies(self) -> None:
        print("Updating rust dependencies...")
        try:
            subprocess.run(["cargo", "update"], cwd="rust")
            print("Rust dependencies updated successfully\n")
        except Exception as e:
            print("Error updating rust dependencies:", str(e))
            return

class FlutterUtils:
    def __init__(self):
        pass

    def clean_project(self) -> None:
        print("Cleaning project...")
        try:
            subprocess.run(["flutter", "clean"])
            print("Project cleaned successfully\n")
        except Exception as e:
            print("Error cleaning project:", str(e))
            return

    def fix_dart_code(self) -> None:
        print("Fixing dart code...")
        try:
            subprocess.run(["dart", "fix", "--apply"])
            print("Dart code fixed successfully\n")
        except Exception as e:
            print("Error fixing dart code:", str(e))
            return

    def update_flutter_dependencies(self) -> None:
        print("Updating flutter dependencies...")
        try:
            subprocess.run(["flutter", "pub", "upgrade"])
            print("Flutter dependencies updated successfully\n")
        except Exception as e:
            print("Error updating flutter dependencies:", str(e))
            return
    
    def clean_pods(self) -> None:
        print("Cleaning pods...")
        try:
            subprocess.run(["flutter", "clean"])
            subprocess.run(["rm", "-rf", IOS_PODS_FILES])
            subprocess.run(["rm", "-rf", MACOS_PODS_FILES])
            subprocess.run(["rm", "-rf", "ios/.symlinks"])
            subprocess.run(["rm", "-rf", "ios/Flutter/Flutter.framework"])
            subprocess.run(["rm", "-rf", "macos/Flutter/Flutter.framework"])
            subprocess.run(["rm", "-rf", "macos/Flutter/Flutter.podspec"])
            print("Pods cleaned successfully\n")
        except Exception as e:
            print("Error cleaning pods:", str(e))
            return


class BuildDocs:
    def __init__(self):
        pass

    def run(self) -> None:
        print("Building documentation...")
        command: List[str] = ["yarn", "start"]
        try:
            if platform.system() == "Windows":
                subprocess.run(command, cwd="website", shell=True)
            else:
                subprocess.run(command, cwd="website")
            print("Documentation built successfully\n")
        except Exception as e:
            print("Error building documentation:", str(e))
            return

    def build(self) -> None:
        print("Building documentation...")
        command: List[str] = ["yarn", "build"]
        try:
            if platform.system() == "Windows":
                subprocess.run(command, cwd="website", shell=True)
            else:
                subprocess.run(command, cwd="website")
            print("Documentation built successfully\n")
        except Exception as e:
            print("Error building documentation:", str(e))
            return

    def upgrade(self) -> None:
        print("Upgrading documentation...")
        command: List[str] = [
            "yarn",
            "upgrade",
            "@docusaurus/core@latest",
            "@docusaurus/preset-classic@latest",
            "@docusaurus/module-type-aliases@latest",
            "@docusaurus/tsconfig@latest",
            "@docusaurus/types@latest",
        ]
        try:
            if platform.system() == "Windows":
                subprocess.run(command, cwd="website", shell=True)
            else:
                subprocess.run(command, cwd="website")
            print("Documentation upgraded successfully\n")
        except Exception as e:
            print("Error upgrading documentation:", str(e))
            return


class Args:
    def __init__(self):
        pass

    def get_args(self) -> argparse.Namespace:
        parser = argparse.ArgumentParser(
            description="Various build scripts for the project"
        )
        subparsers = parser.add_subparsers(
            dest="command", help="Commands for build scripts"
        )
        self.get_flutter_build_args(subparsers)
        self.get_flutter_utils_args(subparsers)
        self.get_rust_build_args(subparsers)
        self.get_doc_build_args(subparsers)

        return parser.parse_args()

    def get_flutter_build_args(self, args: argparse.Namespace) -> None:
        parser = args.add_parser("build", help="Build project")
        parser.add_argument("--all", action="store_true", help="Build all platforms")
        parser.add_argument("--android", action="store_true", help="Build android")
        parser.add_argument("--apk", action="store_true", help="Build apk")
        parser.add_argument("--bundle", action="store_true", help="Build bundle")
        parser.add_argument("--ios", action="store_true", help="Build ios")
        parser.add_argument("--linux", action="store_true", help="Build linux")
        parser.add_argument("--macos", action="store_true", help="Build macos")
        parser.add_argument("--windows", action="store_true", help="Build windows")

    def get_flutter_utils_args(self, args: argparse.Namespace) -> None:
        parser = args.add_parser("utils", help="Utilities for Flutter project")
        parser.add_argument("--clean", action="store_true", help="Clean project")
        parser.add_argument("--fix", action="store_true", help="Fix dart code")
        parser.add_argument(
            "--update", action="store_true", help="Update flutter dependencies"
        )
        parser.add_argument("--clean-pods", action="store_true", help="Clean pods")

    def get_rust_build_args(self, args: argparse.Namespace) -> None:
        parser = args.add_parser("frb", help="Build options for Rust project")
        parser.add_argument("--generate", action="store_true", help="Generate frb code")
        parser.add_argument(
            "--check", action="store_true", help="Check rust dependencies"
        )
        parser.add_argument(
            "--update", action="store_true", help="Update rust dependencies"
        )
        parser.add_argument(
            "--upgrade", action="store_true", help="Upgrade frb executable"
        )
        parser.add_argument("--clean", action="store_true", help="Clean project")
        parser.add_argument("--clean-all", action="store_true", help="Clean FRB files")
        parser.add_argument("--install", action="store_true", help="Install frb executable")

    def get_doc_build_args(self, args: argparse.Namespace) -> None:
        parser = args.add_parser("docs", help="Build documentation")
        parser.add_argument("--run", action="store_true", help="Run documentation")
        parser.add_argument("--build", action="store_true", help="Build documentation")
        parser.add_argument(
            "--upgrade", action="store_true", help="Upgrade documentation"
        )


class Parser:
    def __init__(self, args: argparse.Namespace):
        self.args = args

    def parse_build_args(self) -> None:
        build = Build()
        if self.args.android:
            build.build_android()
        elif self.args.apk:
            build.build_apk()
        elif self.args.bundle:
            build.build_bundle()
        elif self.args.ios:
            build.build_ios()
        elif self.args.linux:
            build.build_linux()
        elif self.args.macos:
            build.build_macos()
        elif self.args.windows:
            build.build_windows()
        elif self.args.all:
            build.build_all()
        else:
            print("No platform selected")

    def parse_flutter_utils_args(self) -> None:
        utils = FlutterUtils()
        if self.args.clean:
            utils.clean_project()
        elif self.args.fix:
            utils.fix_dart_code()
        elif self.args.update:
            utils.update_flutter_dependencies()
        elif self.args.clean_pods:
            utils.clean_pods()
        else:
            print("No utility option selected")
            return

    def parse_rust_build_args(self) -> None:
        rust = BuildRust()
        if self.args.generate:
            rust.generate_frb_code(self.args.clean)
        elif self.args.check:
            rust.check_rust_dependencies()
        elif self.args.update:
            rust.update_rust_dependencies()
        elif self.args.upgrade:
            rust.update_frb_executable()
        elif self.args.install:
            rust.install_frb_executable()
        elif self.args.clean_all:
            rust.clean_frb_files()
        else:
            print("No build option selected")
            return

    def parse_doc_build_args(self) -> None:
        docs = BuildDocs()
        if self.args.run:
            docs.run()
        elif self.args.build:
            docs.build()
        elif self.args.upgrade:
            docs.upgrade()
        else:
            print("No documentation option selected")
            return


def main() -> None:
    args = Args().get_args()
    parser = Parser(args)
    if args.command == "build":
        parser.parse_build_args()
    elif args.command == "utils":
        parser.parse_flutter_utils_args()
    elif args.command == "frb":
        parser.parse_rust_build_args()
    elif args.command == "docs":
        parser.parse_doc_build_args()
    else:
        print("No command selected")


if __name__ == "__main__":
    main()
