import emitter, platform

type Compiler* = ref object of Emitter
  platform*: Platform