# Razorpay SDK
-keep class com.razorpay.** { *; }
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn com.razorpay.**

# Keep annotations
-keepattributes *Annotation*

# Prevent stripping methods used via reflection
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
    public *;
}

# General settings to avoid issues with third-party libraries
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**
-dontwarn okio.**
-dontwarn retrofit2.**