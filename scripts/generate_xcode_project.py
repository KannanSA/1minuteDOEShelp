#!/usr/bin/env python3
"""Generate Xcode project, asset catalogs, and app icons for the three iOS targets."""

from __future__ import annotations

import hashlib
import os
import struct
import zlib
from pathlib import Path

ROOT = Path("/workspace")


def xid(*parts: str) -> str:
    return hashlib.md5("|".join(parts).encode()).hexdigest()[:24].upper()


def png_chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def write_png(path: Path, width: int, height: int, pixel_at) -> None:
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            r, g, b, a = pixel_at(x, y, width, height)
            raw.extend((r & 255, g & 255, b & 255, a & 255))
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", ihdr) + png_chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + png_chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def dist(x, y, cx, cy):
    return ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5


def icon_one_minute(x, y, w, h):
    cx, cy = w / 2, h / 2
    d = dist(x, y, cx, cy)
    r = min(w, h) * 0.42
    bg = (255, 227, 209, 255)
    if d > r + 8:
        return bg
    ring_outer, ring_inner = r, r - w * 0.08
    if ring_inner <= d <= ring_outer:
        return (245, 122, 92, 255)
    # inner peach
    return (255, 214, 190, 255)


def icon_ifat(x, y, w, h):
    cx, cy = w / 2, h / 2
    d = dist(x, y, cx, cy)
    cream = (247, 240, 224, 255)
    sage = (120, 150, 125, 255)
    if d < min(w, h) * 0.28:
        return sage
    # soft vignette
    t = min(1.0, d / (min(w, h) * 0.7))
    return (lerp(247, 232, t), lerp(240, 228, t), lerp(224, 210, t), 255)


def icon_okgym(x, y, w, h):
    # black field, volt bar
    bar_top = int(h * 0.42)
    bar_bot = int(h * 0.58)
    bar_l = int(w * 0.18)
    bar_r = int(w * 0.82)
    if bar_l <= x <= bar_r and bar_top <= y <= bar_bot:
        return (211, 255, 23, 255)
    return (12, 12, 12, 255)


ASSET_ROOT = {
    "info": {"author": "xcode", "version": 1},
}


def write_json(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)


def write_asset_catalog(app_dir: Path, accent: dict, icon_fn) -> None:
    assets = app_dir / "Assets.xcassets"
    write_json(
        assets / "Contents.json",
        """{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
""",
    )
    write_json(
        assets / "AccentColor.colorset" / "Contents.json",
        f"""{{
  "colors" : [
    {{
      "color" : {{
        "color-space" : "srgb",
        "components" : {{
          "alpha" : "1.000",
          "blue" : "{accent['b']}",
          "green" : "{accent['g']}",
          "red" : "{accent['r']}"
        }}
      }},
      "idiom" : "universal"
    }}
  ],
  "info" : {{
    "author" : "xcode",
    "version" : 1
  }}
}}
""",
    )
    write_json(
        assets / "AppIcon.appiconset" / "Contents.json",
        """{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
""",
    )
    write_png(assets / "AppIcon.appiconset" / "AppIcon.png", 1024, 1024, icon_fn)


def scheme_xml(blueprint_id: str, buildable_name: str, blueprint_name: str) -> str:
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForAnalyzing = "YES"
            buildForArchiving = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{blueprint_id}"
               BuildableName = "{buildable_name}"
               BlueprintName = "{blueprint_name}"
               ReferencedContainer = "container:KannanApps.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{blueprint_id}"
            BuildableName = "{buildable_name}"
            BlueprintName = "{blueprint_name}"
            ReferencedContainer = "container:KannanApps.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{blueprint_id}"
            BuildableName = "{buildable_name}"
            BlueprintName = "{blueprint_name}"
            ReferencedContainer = "container:KannanApps.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""


def pbx_file_ref(file_id: str, path: str, file_type: str, extras: str = "") -> str:
    extra = extras + " " if extras else ""
    return f"\t\t{file_id} /* {path} */ = {{isa = PBXFileReference; {extra}lastKnownFileType = {file_type}; path = {quote(path)}; sourceTree = \"<group>\"; }};\n"


def quote(value: str) -> str:
    if any(ch in value for ch in " ./-+"):
        return f'"{value}"'
    return value


def build_settings(debug: bool, extra: dict) -> str:
    common = {
        "ALWAYS_SEARCH_USER_PATHS": "NO",
        "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
        "CLANG_ANALYZER_NONNULL": "YES",
        "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION": "YES_AGGRESSIVE",
        "CLANG_CXX_LANGUAGE_STANDARD": '"gnu++20"',
        "CLANG_ENABLE_MODULES": "YES",
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_ENABLE_OBJC_WEAK": "YES",
        "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
        "CLANG_WARN_BOOL_CONVERSION": "YES",
        "CLANG_WARN_COMMA": "YES",
        "CLANG_WARN_CONSTANT_CONVERSION": "YES",
        "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
        "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR",
        "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES",
        "CLANG_WARN_EMPTY_BODY": "YES",
        "CLANG_WARN_ENUM_CONVERSION": "YES",
        "CLANG_WARN_INFINITE_RECURSION": "YES",
        "CLANG_WARN_INT_CONVERSION": "YES",
        "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
        "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
        "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",
        "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
        "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
        "CLANG_WARN_STRICT_PROTOTYPES": "YES",
        "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
        "CLANG_WARN_UNGUARDED_AVAILABILITY": "YES_AGGRESSIVE",
        "CLANG_WARN_UNREACHABLE_CODE": "YES",
        "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
        "COPY_PHASE_STRIP": "NO",
        "ENABLE_STRICT_OBJC_MSGSEND": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "GCC_C_LANGUAGE_STANDARD": "gnu17",
        "GCC_NO_COMMON_BLOCKS": "YES",
        "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
        "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
        "GCC_WARN_UNDECLARED_SELECTOR": "YES",
        "GCC_WARN_UNINITIALIZED_AUTOS": "YES_AGGRESSIVE",
        "GCC_WARN_UNUSED_FUNCTION": "YES",
        "GCC_WARN_UNUSED_VARIABLE": "YES",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.6",
        "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
        "MTL_FAST_MATH": "YES",
        "SDKROOT": "iphoneos",
    }
    if debug:
        common.update(
            {
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "ENABLE_TESTABILITY": "YES",
                "GCC_DYNAMIC_NO_PIC": "NO",
                "GCC_OPTIMIZATION_LEVEL": "0",
                "GCC_PREPROCESSOR_DEFINITIONS": "(\n\t\t\t\t\t\"DEBUG=1\",\n\t\t\t\t\t\"$(inherited)\",\n\t\t\t\t)",
                "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
                "ONLY_ACTIVE_ARCH": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": '"DEBUG $(inherited)"',
                "SWIFT_OPTIMIZATION_LEVEL": '"-Onone"',
            }
        )
    else:
        common.update(
            {
                "DEBUG_INFORMATION_FORMAT": '"dwarf-with-dsym"',
                "ENABLE_NS_ASSERTIONS": "NO",
                "MTL_ENABLE_DEBUG_INFO": "NO",
                "SWIFT_COMPILATION_MODE": "wholemodule",
                "VALIDATE_PRODUCT": "YES",
            }
        )
    common.update(extra)
    lines = []
    for key in sorted(common):
        lines.append(f"\t\t\t\t{key} = {common[key]};")
    return "\n".join(lines)


def target_settings(bundle_id: str, display_name: str, debug: bool) -> str:
    extra = {
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "DEVELOPMENT_TEAM": '""',
        "ENABLE_PREVIEWS": "YES",
        "GENERATE_INFOPLIST_FILE": "YES",
        "INFOPLIST_KEY_CFBundleDisplayName": quote(display_name),
        "INFOPLIST_KEY_LSApplicationCategoryType": '"public.app-category.healthcare-fitness"',
        "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
        "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
        "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations": "UIInterfaceOrientationPortrait",
        "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": '"UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown"',
        "LD_RUNPATH_SEARCH_PATHS": '(\n\t\t\t\t\t"$(inherited)",\n\t\t\t\t\t"@executable_path/Frameworks",\n\t\t\t\t)',
        "MARKETING_VERSION": "1.0",
        "PRODUCT_BUNDLE_IDENTIFIER": bundle_id,
        "PRODUCT_NAME": '"$(TARGET_NAME)"',
        "SUPPORTED_PLATFORMS": '"iphoneos iphonesimulator"',
        "SUPPORTS_MACCATALYST": "NO",
        "SWIFT_EMIT_LOC_STRINGS": "YES",
        "SWIFT_VERSION": "5.0",
        "TARGETED_DEVICE_FAMILY": '"1"',
    }
    if debug:
        extra["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = '"DEBUG $(inherited)"'
        extra["SWIFT_OPTIMIZATION_LEVEL"] = '"-Onone"'
    return build_settings(debug, extra)


TARGETS = [
    {
        "name": "OneMinuteDOESHelp",
        "folder": "OneMinuteDOESHelp",
        "product": "OneMinuteDOESHelp.app",
        "display": "1 Minute DOES Help",
        "bundle": "com.kannan.OneMinuteDOESHelp",
        "sources": [
            "OneMinuteDOESHelpApp.swift",
            "Theme.swift",
            "MinuteTimer.swift",
            "StreakStore.swift",
            "MinuteRingView.swift",
            "HomeView.swift",
        ],
        "resources": ["Assets.xcassets", "PrivacyInfo.xcprivacy"],
    },
    {
        "name": "iFat",
        "folder": "iFat",
        "product": "iFat.app",
        "display": "iFat",
        "bundle": "com.kannan.iFat",
        "sources": [
            "iFatApp.swift",
            "Theme.swift",
            "WellbeingStore.swift",
            "CareRingView.swift",
            "HomeView.swift",
        ],
        "resources": ["Assets.xcassets", "PrivacyInfo.xcprivacy"],
    },
    {
        "name": "OKGym",
        "folder": "OKGym",
        "product": "OKGym.app",
        "display": "OK Gym",
        "bundle": "com.kannan.OKGym",
        "sources": [
            "OKGymApp.swift",
            "Theme.swift",
            "GymStore.swift",
            "HomeView.swift",
            "WorkoutSessionView.swift",
        ],
        "resources": ["Assets.xcassets", "PrivacyInfo.xcprivacy"],
    },
]


def generate_pbxproj() -> str:
    project_id = xid("project")
    main_group = xid("main_group")
    products_group = xid("products")
    project_debug = xid("proj", "debug")
    project_release = xid("proj", "release")
    project_configs = xid("proj", "configs")

    file_refs = []
    build_files = []
    groups = []
    native_targets = []
    sources_phases = []
    resources_phases = []
    frameworks_phases = []
    target_configs = []
    config_lists = []
    product_refs = []
    target_ids = []
    group_children = []

    for target in TARGETS:
        tname = target["name"]
        tid = xid("target", tname)
        target_ids.append((tid, tname))
        product_id = xid("product", tname)
        product_refs.append(f"\t\t\t\t{product_id} /* {target['product']} */,\n")
        file_refs.append(
            f"\t\t{product_id} /* {target['product']} */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {target['product']}; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
        )
        folder_group = xid("group", tname)
        group_children.append(f"\t\t\t\t{folder_group} /* {tname} */,\n")

        source_phase = xid("sources", tname)
        resource_phase = xid("resources", tname)
        frameworks_phase = xid("frameworks", tname)
        debug_cfg = xid("tcfg", tname, "debug")
        release_cfg = xid("tcfg", tname, "release")
        cfg_list = xid("tlist", tname)

        source_build = []
        resource_build = []
        child_refs = []

        for src in target["sources"]:
            fid = xid("file", tname, src)
            bfid = xid("build", tname, src)
            file_refs.append(pbx_file_ref(fid, src, "sourcecode.swift"))
            build_files.append(
                f"\t\t{bfid} /* {src} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {src} */; }};\n"
            )
            source_build.append(f"\t\t\t\t{bfid} /* {src} in Sources */,\n")
            child_refs.append(f"\t\t\t\t{fid} /* {src} */,\n")

        for res in target["resources"]:
            fid = xid("file", tname, res)
            bfid = xid("build", tname, res)
            ftype = "folder.assetcatalog" if res.endswith(".xcassets") else "text.xml"
            file_refs.append(pbx_file_ref(fid, res, ftype))
            build_files.append(
                f"\t\t{bfid} /* {res} in Resources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {res} */; }};\n"
            )
            resource_build.append(f"\t\t\t\t{bfid} /* {res} in Resources */,\n")
            child_refs.append(f"\t\t\t\t{fid} /* {res} */,\n")

        groups.append(
            f"""\t\t{folder_group} /* {tname} */ = {{
			isa = PBXGroup;
			children = (
{''.join(child_refs)}\t\t\t);
			path = {tname};
			sourceTree = "<group>";
		}};
"""
        )

        native_targets.append(
            f"""\t\t{tid} /* {tname} */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {cfg_list} /* Build configuration list for PBXNativeTarget "{tname}" */;
			buildPhases = (
				{source_phase} /* Sources */,
				{frameworks_phase} /* Frameworks */,
				{resource_phase} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = {tname};
			productName = {tname};
			productReference = {product_id} /* {target['product']} */;
			productType = "com.apple.product-type.application";
		}};
"""
        )

        sources_phases.append(
            f"""\t\t{source_phase} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{''.join(source_build)}\t\t\t);
			runOnlyForDeploymentPostprocessing = 0;
		}};
"""
        )
        resources_phases.append(
            f"""\t\t{resource_phase} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{''.join(resource_build)}\t\t\t);
			runOnlyForDeploymentPostprocessing = 0;
		}};
"""
        )
        frameworks_phases.append(
            f"""\t\t{frameworks_phase} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
"""
        )

        for cfg_id, cfg_name, is_debug in (
            (debug_cfg, "Debug", True),
            (release_cfg, "Release", False),
        ):
            target_configs.append(
                f"""\t\t{cfg_id} /* {cfg_name} */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{target_settings(target['bundle'], target['display'], is_debug)}
			}};
			name = {cfg_name};
		}};
"""
            )

        config_lists.append(
            f"""\t\t{cfg_list} /* Build configuration list for PBXNativeTarget "{tname}" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_cfg} /* Debug */,
				{release_cfg} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
"""
        )

    groups.insert(
        0,
        f"""\t\t{main_group} = {{
			isa = PBXGroup;
			children = (
{''.join(group_children)}\t\t\t\t{products_group} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{products_group} /* Products */ = {{
			isa = PBXGroup;
			children = (
{''.join(product_refs)}\t\t\t);
			name = Products;
			sourceTree = "<group>";
		}};
""",
    )

    target_attrs = "".join(
        f"""\t\t\t\t\t{tid} = {{
						CreatedOnToolsVersion = 16.0;
					}};
"""
        for tid, _ in target_ids
    )

    target_list = "".join(f"\t\t\t\t{tid} /* {name} */,\n" for tid, name in target_ids)

    for cfg_id, cfg_name, is_debug in (
        (project_debug, "Debug", True),
        (project_release, "Release", False),
    ):
        target_configs.insert(
            0,
            f"""\t\t{cfg_id} /* {cfg_name} */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
{build_settings(is_debug, {})}
			}};
			name = {cfg_name};
		}};
""",
        )

    config_lists.insert(
        0,
        f"""\t\t{project_configs} /* Build configuration list for PBXProject "KannanApps" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{project_debug} /* Debug */,
				{project_release} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
""",
    )

    return f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{''.join(build_files)}/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{''.join(file_refs)}/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
{''.join(frameworks_phases)}/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{''.join(groups)}/* End PBXGroup section */

/* Begin PBXNativeTarget section */
{''.join(native_targets)}/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
				TargetAttributes = {{
{target_attrs}\t\t\t\t}};
			}};
			buildConfigurationList = {project_configs} /* Build configuration list for PBXProject "KannanApps" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group};
			productRefGroup = {products_group} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
{target_list}\t\t\t);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
{''.join(resources_phases)}/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
{''.join(sources_phases)}/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
{''.join(target_configs)}/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
{''.join(config_lists)}/* End XCConfigurationList section */
	}};
	rootObject = {project_id} /* Project object */;
}}
"""


def main() -> None:
    write_asset_catalog(
        ROOT / "OneMinuteDOESHelp",
        {"r": "0.960", "g": "0.480", "b": "0.360"},
        icon_one_minute,
    )
    write_asset_catalog(
        ROOT / "iFat",
        {"r": "0.470", "g": "0.590", "b": "0.490"},
        icon_ifat,
    )
    write_asset_catalog(
        ROOT / "OKGym",
        {"r": "0.830", "g": "1.000", "b": "0.090"},
        icon_okgym,
    )

    pbx = ROOT / "KannanApps.xcodeproj" / "project.pbxproj"
    pbx.parent.mkdir(parents=True, exist_ok=True)
    pbx.write_text(generate_pbxproj())

    workspace = ROOT / "KannanApps.xcodeproj" / "project.xcworkspace" / "contents.xcworkspacedata"
    write_json(
        workspace,
        """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
""",
    )

    schemes = ROOT / "KannanApps.xcodeproj" / "xcshareddata" / "xcschemes"
    schemes.mkdir(parents=True, exist_ok=True)
    mapping = [
        ("OneMinuteDOESHelp", "OneMinuteDOESHelp.app", "One Minute DOES Help"),
        ("iFat", "iFat.app", "iFat"),
        ("OKGym", "OKGym.app", "OK Gym"),
    ]
    for name, product, _label in mapping:
        (schemes / f"{name}.xcscheme").write_text(scheme_xml(xid("target", name), product, name))

    print("Generated Xcode project, assets, and schemes.")


if __name__ == "__main__":
    main()
