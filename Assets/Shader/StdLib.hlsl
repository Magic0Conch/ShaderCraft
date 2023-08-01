float calculateBrightness(fixed3 col){
	return max(dot(col,fixed3(.3f, .59f, .11f)),6.10352e-5);
}

float randomNoise(float x,float y){
	return frac(sin(dot(float2(x,y),float2(19.9898,78.233))) *43758.5453);
}
float fmod_c(float dividend, float divisor) {
    if (divisor == 0.0f) {
        return 0.0f;
    }

    float quotient = dividend / divisor;
    float integerPart = floor(quotient);
    float remainder = dividend - integerPart * divisor;

    return remainder;
}