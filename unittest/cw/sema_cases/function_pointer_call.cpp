struct CallbackHolder {
  int (*callback)(short);
  int (*(*factory)())(short);
};
int FunctionPointerCall(CallbackHolder holder, int (*callback)(short), signed char value) {
  callback(value);
  (holder.factory)()(value);
  return (holder.callback)(value);
}
