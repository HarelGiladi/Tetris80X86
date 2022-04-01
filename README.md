# Tetris80X86
Tetris in Assembly 80X86
This is an old Project of mine.
it runs well but lacks some features that need to be added:

    -score and sign in board(NO code)
    -delete rows when complete(there is a bug)
    -There is no way to be disqualfied(there is a bug)
    
    
    
   # How To Run:
   first of all, we need to understand that we are talking about an old language,
   that needs to run on a specific old type of computer,
   Because modern operating systems are not backward compatible with 80x86 processors and their address space.
   There is a software called an emulator that mimics a computer or operating system.

   
   ### first step:
        we need an computer emulator that can run our program.
        
        download DosBox u can use this link (probaly expire by now):
            www.cyber.org.il/assembly/dosbox 
            
   ### second step:
        we need an assembler that can tranlate our code to machine language.
        we alse need an linker for an multi file projects(not for this project).
        and finally we need and debuger for trying to figure out bugs.
        
        I choosed to use tasm.
        
        dowmload all three in this link(probaly expire by now):
            http://cyber.org.il/assembly/TASM.rar 
            
  ### tips before running:
        
       -Because we are performing an emulation of an old processor, the running speed of the dosbox has been reduced accordingly,
        and the default is to run At a rate of 3000 cycles per second only. You can change this pace by writing.
        Next command on the DosBox screen:     Cycles = max
        
        -You can set a collection of commands for Dosbox that will run automatically as it turns on.
         Setting these commands can save us a lot of typing - for example, we can configure Dosbox so that each time
         that it turns on, he will immediately reach the right library.
         
         The file where the commands can be set is called conf.74.0-dosbox and can be accessed through the windows-open menu.
         Select Options 74.0 DOSBox from the DOSBox menu.
         than u could write any commands that u like such as:
              mount c: c:\
              c:
              cd tasm
              cd bin
              cycles = max
              
              
              
  ### compiling the program:
        -open DosBOx than reach the location of the file and compile the file. 
        -type the command tasm "fileName".asm in our case its tasm tetris.asm
              if u want to debug add /zi for saving the info required for debuging like so:
              tasm /zi tetris.asm
              it will create an object file named fileName.obj  
              and fileName.map(not important for running)if no errors accured.
        -type the command tlink "fileName".obj in our case its tlink tetris.obj
              if u want to debug add /v for saving the info required for debuging like so:
              tasm /v tetris.asm
              it will create an exe file from an object file named fileName.exe if no errors accured.
        
 
 ### run the program/turbo debugger:
        -now for runing type the command fileName.exe in our case tetris.exe
         and now the program will run.
         you can also go ahead and run the exe file in the reposteroy.
        -for debug type the command td filename in our case td tetris and
         an debug window will popout.
        
        
        
