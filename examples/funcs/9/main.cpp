#include <iostream>

int a (void);
int b (int);

class B {
 public:
  B() {}
  virtual ~B(){}
  virtual int f1() = 0;
  virtual int f2(int x) = 0;
  virtual int f3() { return 1;}
  
};


class D1: public B{
 public:

  D1(): B() {}

  // res = [0,1]
  virtual int f1() {
    int x = 0;
    x++;
    return x;
  }
  
  // res >= x and res <= x+1
  virtual int f2(int x) {
    return x++;
  }
};


class D2: public B {
  int m_x;
 public:
  D2(): B(), m_x(0) {}

  // res = 5
  virtual int f1() {
    return 2;
  }

  // res = x + 10
  virtual int f2(int x)  {
    //return x + m_x + 10;
    return x + 10;
  }  
};


int main(int argc, char* argv[]) {
  B* p = 0;
  if (argc > 3) {
    p = new D1();
  } else {
    p = new D2();    
  }

  int r1 = p->f1();
  int r2 = p->f2(argc);
  int r3 = p->f3();

  //std::cout <<  r1+r2+r3 << std::endl;
  
  delete p;
  
  return r1+r2+r3;
}
