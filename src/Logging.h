
#ifndef _LOGGING_H_
#define _LOGGING_H_

#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"


/*
Ian's simple logging.

Note we are creating a loging object per LLVM function call, not ideal
but will do for now. We should be able to restrict this to once per pass.


Don't be surprised if you have to add a 


  friend Logging &operator << (Logging &logger, WeirdLLVMThing thing) {
    *(logger.raw_os) << thing;
    return logger;
  }

every now and then.

The logging gets used thusly:


#include "Logging.h"

int CrazyAssedPass::foo() {

    // Create object
    //
    //            location                optional destination
    //               V                          V
    Logging log ("CrazyAssedPass::foo()", "testfile.txt");

    // Writing warnings or errors to file is very easy and C++ style
    log << Logging::level::LOG_WARNING << "A warning (location gets added)";
    log << Logging::level::LOG_ERROR << "An error, also triggers adding location";
    log << "This is just a simple text, no location or level"; 

    return 0;
}
*/

using namespace llvm;


class Logging {

 public:

  enum level { ERROR, WARNING, INFO };

  explicit Logging (const char *loc, const char *fname = "occam_log.txt")
  {
    std::string ecode;
    
    this->location = loc;
    
    raw_os = new raw_fd_ostream (fname, ecode, llvm::sys::fs::OpenFlags::F_Append);
    
  }
  
  
  ~Logging () {
    raw_os->close();
    delete raw_os;
  }

  // Overload << operator using log type
  friend Logging &operator << (Logging &logger, const level lvl) {
    
    switch (lvl) {
    case Logging::level::ERROR:
      *(logger.raw_os) << "[ERROR] " << logger.location << ":\n";
      break;
      
    case Logging::level::WARNING:
      *(logger.raw_os) << "[WARNING] " << logger.location << ":\n";
      break;
      
    default:
      *(logger.raw_os) << "[INFO] " << logger.location << ":\n ";
      break;
    } 
    return logger;
  }
  
  friend Logging &operator << (Logging &logger, llvm::FunctionType *ftype) {
    *(logger.raw_os) << ftype;
    return logger;
  }

  friend Logging &operator << (Logging &logger, const char *text) {
    *(logger.raw_os) << text ;
    return logger;
  }

  friend Logging &operator << (Logging &logger, const int num) {
    *(logger.raw_os) << num;
    return logger;
  }

  //Cannot copy a logging object ...
  Logging (const Logging &) = delete;
  Logging &operator= (const Logging &) = delete;
  
 private:

  raw_fd_ostream         *raw_os;
  const char             *location;
  
}; 



#endif //_LOGGING_H_

