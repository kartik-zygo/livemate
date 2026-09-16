# R8 rules for the Livemate release build.
#
# The Flutter Gradle plugin already contributes the keep rules for the engine
# and the embedding. What is left is the handful of things R8 cannot see are
# reachable because they are reached over a platform channel or by reflection.

# Flutter embedding — referenced from the manifest and from native code.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Plugin registrant is generated and referenced reflectively.
-keep class io.flutter.plugins.** { *; }

# image_picker hands back a content URI through a FileProvider declared in the
# merged manifest; the class is never referenced from Java we compile.
-keep class androidx.core.content.FileProvider { *; }
-keep class * extends androidx.core.content.FileProvider { *; }

# Play Core is referenced by the deferred-components code path that Flutter
# compiles in unconditionally. This app does not use deferred components, so
# the classes are genuinely absent — silence the warning rather than adding the
# dependency.
-dontwarn com.google.android.play.core.**

# Keep annotations and generic signatures so reflection-based JSON handling in
# any plugin keeps working.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Line numbers in Play Console crash reports. Without SourceFile the traces are
# unreadable; renaming it to a constant keeps the class names obfuscated.
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile
