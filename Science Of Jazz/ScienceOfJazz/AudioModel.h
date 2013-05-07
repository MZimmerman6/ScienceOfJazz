//
//  AudioModel.h
//  Spectrum3D
//
//  Created by Garth Griffin on 5/23/10.
//  Copyright Garth Griffin 2010. 
//

/*
 
 This file describes a shape that consists of a top, a front, and two sides.
 It has no back or bottom.
 
 Calling the AudioModelMake function allocates all the memory required to store 
 vertex, color, and triangle strip data for a model with the passed data dimensions.
 It returns an AudioModel struct, a pointer to which must be passed to the other 
 functions as the first parameter. The struct can be considered opaque.
 
 The dimensions of the model in virtual space are set using AudioModelSetDimensions.
 
 A new row of data is added to the front of the model by calling AudioModelAddXData.
 This also removes the back row of data.
 
 Calling AudioModelDrawElements calls the GL drawing functions required to draw the model.
 
 All alloc'd memory is freed by calling AudioModelDestroy.

 */

#import "OpenGLCommon.h"


// vertex normals are needed for materials/lights
#define USE_VERTEX_NORMALS 0


// set up the struct
typedef struct {
	
	// dimensions in visual space
	GLfloat length;
	GLfloat width;
	GLfloat height;
	
	// dimensions in audio space
	GLuint xDataLen;
	GLuint zDataLen;
	
	// vertex, color, and normal pointers
	Vertex3D *vertices;
	Color3D *colors;
#if USE_VERTEX_NORMALS
	Vector3D *vertexNormals;
#endif
	GLuint numVertices;
	
	// triangle strip pointers
	GLushort **topTrilists;
	GLushort *sideTrilists[2];
	GLushort *frontTrilist;
	GLushort numTopTrilists;
	GLuint xTrilistLen;
	GLuint zTrilistLen;
	
} AudioModel;

AudioModel AudioModelMake(GLuint xDataLen, GLuint zDataLen);
void AudioModelSetDimensions(AudioModel* m, GLfloat length, GLfloat width, GLfloat height);
void AudioModelDrawElements(AudioModel* m);
void AudioModelAddXData(AudioModel* m, GLfloat* newXData, int modelNum);
void AudioModelDestroy(AudioModel* m);

GLuint vertsSectionLength(int section);
GLuint vertsSectionFirstIndex(int section);
GLuint vertsFront(int x);
GLuint vertsSide(int side, int z);
GLuint vertsTop(int x, int z);
void setVertexCoords(AudioModel* m);
