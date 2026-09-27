// C++ needs a declaration before a call; CW resolves the later definition.
int Later();

int ForwardCall() { return Later(); }
int Later() { return 37; }
