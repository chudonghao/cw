struct Tag {
  int tag;
};
struct Product {
  int value;
};
// Product follows Tag in Special, at offset four.
struct Special : Tag, Product {};

// Plain and Maker are defined in another translation unit, as CW's imported declarations are.
struct Plain {
  virtual int Id() const;
  virtual Product* Item() const;
  Plain();
  ~Plain();
};
struct Maker {
  virtual Product* Make() const;
  virtual const Product& Get() const;
  Maker();
  ~Maker();
};

// Through Maker, the thunks adjust the receiver to Factory and the result to Product. Item
// overrides the primary base Plain but needs a result adjustment, so it takes a new slot and
// Plain's slot only adjusts the result.
// C++ destructors restore the base vptrs in the base destructors; CW leaves Factory's dispatch
// in Factory's destructor.
struct Factory : Plain, Maker {
  Special* Make() const override;
  const Special& Get() const override;
  Special* Item() const override;
  Special* target;
  explicit Factory(Special* target);
  ~Factory();
};
Special* Factory::Make() const { return target; }
const Special& Factory::Get() const { return *target; }
Special* Factory::Item() const { return target; }
Factory::Factory(Special* input) : Plain(), Maker(), target(input) {}
Factory::~Factory() {}

Product* MakeThrough(const Maker& maker) { return maker.Make(); }
const Product& GetThrough(const Maker& maker) { return maker.Get(); }
Special* MakeDirect(const Factory& factory) { return factory.Make(); }
