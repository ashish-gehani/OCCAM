/*
 * OCCAM
 *
 * Copyright (c) 2011-2016, SRI International
 *
 *  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of SRI International nor the names of its contributors may
 *   be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _LOGGING_H_
#define _LOGGING_H_

#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"


/*
 * Logging.h
 *
 *  Created on: Feb 8, 2016
 *      Author: iam
 *
 * Ian's simple logging (features added only on demand).
 * 
 * Note we are currently creating a logging object per LLVM pass.
 * 
 * Don't be surprised if you have to add a 
 * 
 *   friend Logging &operator << (Logging &logger, WeirdLLVMThing thing) {
 *     *(logger.raw_os) << thing;
 *     return logger;
 *   }
 * 
 * every now and then.
 * 
 * The logging gets used thusly:
 * 
 * 
 * #include "Logging.h"
 * 
 * int CrazyAssedPass::foo() {
 * 
 *     // Create object
 *     //
 *     //            location                optional destination
 *     //               V                          V
 *     Logging log ("CrazyAssedPass::foo()", "testfile.txt");
 * 
 *     // Writing warnings or errors to file is very easy and C++ style
 *     log << Logging::level::LOG_WARNING << "A warning (location gets added)";
 *     log << Logging::level::LOG_ERROR << "An error, also triggers adding location";
 *     log << "This is just a simple text, no location or level"; 
 * 
 *     return 0;
 * }
 *
 */

using namespace llvm;


class Logging {

 public:

  enum level { ERROR, WARNING, INFO };

  explicit Logging (const char *loc, const char *fname = "occam_llvm_log.txt")
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

  //Must not copy a logging object ...
  Logging (const Logging &) = delete;
  Logging &operator= (const Logging &) = delete;
  
 private:

  raw_fd_ostream         *raw_os;
  const char             *location;
  
}; 



#endif //_LOGGING_H_

