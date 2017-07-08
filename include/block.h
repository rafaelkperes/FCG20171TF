#ifndef _BLOCK_H
#define _BLOCK_H

#include <string>
#include <random>
#include <iostream>

#include "object.h"

#define OTHER        0
#define MOVING_BLOCK 1
#define STATIC_BLOCK 2
#define PLANE        3

static const char CUBE_NAME[] = "cube";
const char* BLOCK_NAMES[] = {CUBE_NAME};

typedef ObjModel BlockModel;
typedef SceneObject Block;

BlockModel* getRandomBlockModel() {
  int r = rand() % (sizeof(BLOCK_NAMES) / sizeof(char*));
  const char* blockName = BLOCK_NAMES[r];
  std::string name = "../../data/";
  name += blockName;
  name += ".obj";
  const char *cname = name.c_str();

  BlockModel* bmodel = new BlockModel(cname);
  return bmodel;
}

#endif
