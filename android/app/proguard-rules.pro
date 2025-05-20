# Razorpay
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# GRPC + Missing okhttp classes workaround
-keep class com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

# onPayment callbacks
-keepclasseswithmembers class * {
    public void onPayment*(...);
}

# Gson reflection
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
    @com.google.gson.annotations.Expose <fields>;
    public *;
}

# General
-keepattributes *Annotation*
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**
-dontwarn okio.**
-dontwarn retrofit2.**
