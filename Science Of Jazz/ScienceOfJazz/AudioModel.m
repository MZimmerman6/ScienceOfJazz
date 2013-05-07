//
//  AudioModel.m
//  Spectrum3D
//
//  Created by Garth Griffin on 5/23/10.
//  Copyright Garth Griffin 2010. 
//

#import "AudioModel.h"

#define DEBUGGER 0

// colors
const Color3D topColors[4] = {
	{0.0f, 0.0f, 0.0f, 1.0f},
	{0.0f, 0.2f, 1.0f, 1.0f},
	{0.2f, 1.0f, 0.0f, 1.0f},
	{1.0f, 0.0f, 0.2f, 1.0f}
};
const Color3D bottomColor = {0.1f, 0.1f, 0.1f, 1.0f};


/******************************************************************************************/
/*
 The following functions allow the single array of vertices to be conceptually
 divided into front vertices, side vertices, and top vertcies:
	'front' vertices are the bottom row of vertices on the front
	'side' vertices are the bottoms of the sides, alternating LRLR...
		(excluding the nearest row because those are included in 'front vertices')
	'top' vertices are all vertices on the top, ordered (x,z)
 The coordinate system for indexing into these vertices has the origin at the front
 left corner, with positive x extending along the front to the right and positive z
 extending backward perpendicular to x. There is no y/"up" axis.
 */

// globals that must be set for these functions to work correctly
// arguably sloppy and terrible, but these are just convenience methods anyway
GLuint _xDataLen, _zDataLen;

// enums for section dividers
typedef enum {
	VERTICES_FRONT,
	VERTICES_SIDES,
	VERTICES_TOP
} verticesSections;

// enum for left/right side of 'side' vertices
typedef enum {
	VERTICES_SIDE_L,
	VERTICES_SIDE_R
} verticesSides;

// Returns the length of the portion of the vertices array for the passed section.
// The other helper functions rely on this function, so changing it will change
// all the helper functions.
GLuint vertsSectionLength(int section) {
	switch (section) {
		case VERTICES_FRONT:
			return _xDataLen;
			break;
		case VERTICES_SIDES:
			return 2*(_zDataLen-1);
			break;
		case VERTICES_TOP:
			return _xDataLen * _zDataLen;
		default:
			return -1;
			break;
	}
}

// Returns the first index of the portion of the vertices array for the passed section
// (this is based on the length function above).
// All the indexing functions rely on this function.
GLuint vertsSectionFirstIndex(int section) {
	GLuint totalLength = 0;
	for (int i=section-1; i>=0; i--) {
		totalLength += vertsSectionLength(i);
	}
	return totalLength;
}

// Returns index of 'front' vertex based on number of vertices away from left corner
GLuint vertsFront(int x) {
	GLuint offset = vertsSectionFirstIndex(VERTICES_FRONT);
	return (GLuint)(offset + x);
}

// Returns index of 'side' vertex based on which side and the number of vertices
// back from the front. The value for 'z' must be at least 1 (z = 0 vertices are included
// in the 'front' vertices.
GLuint vertsSide(int side, int z) {
	GLuint offset = vertsSectionFirstIndex(VERTICES_SIDES);
	return (GLuint)(offset + 2*(z-1) + side);
}

// Returns index of 'top' vertex based on number of vertices away from front left corner.
GLuint vertsTop(int x, int z) {
	GLuint offset = vertsSectionFirstIndex(VERTICES_TOP);
	return (GLuint)(offset + x*_zDataLen + z);
}


/******************************************************************************************/
#if USE_VERTEX_NORMALS
/*
 Function to calculate sum of surface normals
 for given face list and vertices.
 
 Vertex normals can subsequently be obtained by dividing each 
 sum in vertexNormalsList by the corresponding value in
 vertexNormalsFaceCount.
 */
void calcNormals(GLushort* facesList, 
				 GLuint numFaces, 
				 Vertex3D* vertices, 
				 Vector3D* vertexNormalsList,
				 GLushort* vertexNormalsFaceCount) 
{
	GLushort vertInds[3];
	Vector3D surfaceNormal;
	Triangle3D triangle;
	for (int i=0; i<numFaces; i++) {
		for (int j=0; j<3; j++) {
			vertInds[j] = facesList[i+j];
		}
		triangle = Triangle3DMake(vertices[vertInds[0]], 
								  vertices[vertInds[1]], 
								  vertices[vertInds[2]]);
		surfaceNormal = Triangle3DCalculateSurfaceNormal(triangle);
		Vector3DNormalize(&surfaceNormal);
		for (int j=0; j<3; j++) {
			GLushort index = vertInds[j];
			vertexNormalsList[index] = Vector3DAdd(vertexNormalsList[index], surfaceNormal);
			vertexNormalsFaceCount[index] = vertexNormalsFaceCount[index] + 1;
		}
	}
}
#endif


/******************************************************************************************/
/*
 Subroutines for using an AudioModel.
 */


void setVertexCoords(AudioModel* m) {
	
	// set globals for indexing
	_xDataLen = m->xDataLen;
	_zDataLen = m->zDataLen;
	
	// calculate spacing
	GLfloat rightEdge = m->width/2.;
	GLfloat leftEdge = -1.*rightEdge;
	GLfloat xIncr = m->width/(GLfloat)(m->xDataLen-1);
	GLfloat zIncr = m->length/(GLfloat)(m->zDataLen-1) * -1;
	
	// counters
	GLfloat xVal, zVal;
	GLuint index,indexL,indexR;
	int i;
	
	// front
	for (i=0; i<m->xDataLen; i++) {
		xVal = xIncr * (GLfloat)i + leftEdge;
		index = vertsFront(i);
		Vertex3DSet(&(m->vertices[index]), xVal, 0.0f, 0.0f);
	}
	
	// sides
	for (i=1; i<m->zDataLen; i++) {
		zVal = zIncr * (GLfloat)i;
		indexL = vertsSide(VERTICES_SIDE_L, i);
		indexR = vertsSide(VERTICES_SIDE_R, i);
		Vertex3DSet(&(m->vertices[indexL]), leftEdge, 0.0f, zVal);
		Vertex3DSet(&(m->vertices[indexR]), rightEdge, 0.0f, zVal);
	}	
	
	// top
	for (i=0; i<m->xDataLen; i++) {
		for (int j=0; j<m->zDataLen; j++) {
			GLfloat xVal = xIncr * (GLfloat)i + leftEdge;
			GLfloat zVal = zIncr * (GLfloat)j;
			GLuint index = vertsTop(i, j);
			m->vertices[index].x = xVal;
			m->vertices[index].z = zVal;
		}
	}
}


/******************************************************************************************/
/*
 Main routines for using an AudioModel.
 */

AudioModel AudioModelMake(GLuint xDataLen, GLuint zDataLen) {
	
	// check input params
	if (xDataLen < 2 || zDataLen < 2) {
		NSLog(@"ERROR (AudioModel.AudioModelMake): Vertices parameter cannot be less than two.");
		exit(1);
	}
	
	// new audio model
	AudioModel m;
	
	// assign what we know from params
	m.xDataLen = xDataLen;
	m.zDataLen = zDataLen;
	
	// set global variables for indexing
	_xDataLen = xDataLen;
	_zDataLen = zDataLen;
	
	// calculate number of vertices
	GLuint numVertsFront = vertsSectionLength(VERTICES_FRONT);
	GLuint numVertsSides = vertsSectionLength(VERTICES_SIDES);
	GLuint numVertsTop = vertsSectionLength(VERTICES_TOP);
	GLuint numVertices = numVertsFront+numVertsSides+numVertsTop;
	m.numVertices = numVertices;
	if (numVertices > 65535) {
		NSLog(@"ERROR (AudioModel.AudioModelMake): Number of vertices (%d) cannot exceed max value of GL_UNSIGNED_SHORT (65535).",
			  numVertices);
		exit(1);
	}

	// allocate vertices, colors, and normals arrays
	m.vertices = (Vertex3D*)malloc(sizeof(Vertex3D) * numVertices);
	m.colors = (Color3D*)malloc(sizeof(Color3D) * numVertices);
#if USE_VERTEX_NORMALS
	m.vertexNormals = (Vector3D*)calloc(numVertices, sizeof(Vector3D));
#endif
		
	// set vertex coordinates
	setVertexCoords(&m);
	
	// set colors
	for (int i=0; i<xDataLen; i++) {
		GLuint index = vertsFront(i);
		m.colors[index] = bottomColor;
	}
	for (int i=1; i<zDataLen; i++) {
		GLuint indexL = vertsSide(VERTICES_SIDE_L, i);
		GLuint indexR = vertsSide(VERTICES_SIDE_R, i);
		m.colors[indexL] = bottomColor;
		m.colors[indexR] = bottomColor;
	}
	for (int i=0; i<xDataLen; i++) {
		for (int j=0; j<zDataLen; j++) {
			GLuint index = vertsTop(i, j);
			m.vertices[index].y = 0.0f;
			Color3DSet(&(m.colors[index]), 0.0f, 0.0f, 0.0f, 0.0f);
		}
	}
	
	if (DEBUGGER) {

		NSLog(@"Printing front vertices:");
		for (int i=0; i<xDataLen; i++) {
			NSLog(@"  vertices[%d] = (%.1f, %.1f, %.1f)",
				  i,m.vertices[i].x,m.vertices[i].y,m.vertices[i].z);
		}
		
		NSLog(@"Printing top vertices:");
		for (int i=0; i<xDataLen; i++) {
			for (int j=0; j<zDataLen; j++) {
				GLuint index = vertsTop(i, j);
				NSLog(@"  vertices[%d] = (%.1f, %.1f, %.1f)",
					  index,m.vertices[index].x,m.vertices[index].y,m.vertices[index].z
					  );
			}
		}
	
	}

	// trilist quantities
	int numXTris = 2*(xDataLen-1);
	int numXInds = numXTris+2;
	int numZTris = 2*(zDataLen-1);
	int numZInds = numZTris+2;
	m.xTrilistLen = numXInds;
	m.zTrilistLen = numZInds;
	
	// front trilist
	m.frontTrilist = (GLushort*)malloc(sizeof(GLushort) * numXInds);
	for (int i=0; i<xDataLen; i++) {
		m.frontTrilist[i*2] = vertsTop(i, 0);
		m.frontTrilist[i*2+1] = vertsFront(i);
	}
	
	// side trilists
	for (int i=0; i<2; i++) {
		m.sideTrilists[i] = (GLushort*)malloc(sizeof(GLushort) * numZInds);
		for (int j=0; j<zDataLen; j++) {
			m.sideTrilists[i][j*2] = vertsTop(i*(xDataLen-1), j);
			GLushort bottomElem;
			if (j == 0)
				bottomElem = vertsFront(i*(xDataLen-1));
			else
				bottomElem = vertsSide(i, j);
			m.sideTrilists[i][j*2+1] = bottomElem;
		}
	}
	
	// top trilists
	GLuint numTopTrilists = xDataLen-1;
	m.numTopTrilists = numTopTrilists;
	m.topTrilists = (GLushort**)malloc(sizeof(GLushort*) * numTopTrilists);
	for (int i=0; i<numTopTrilists; i++) {
		m.topTrilists[i] = (GLushort*)malloc(sizeof(GLushort) * numZInds);
		for (int j=0; j<zDataLen; j++) {
			m.topTrilists[i][j*2] = vertsTop(i, j);
			m.topTrilists[i][j*2+1] = vertsTop(i+1, j);
		}
	}
	
#if USE_VERTEX_NORMALS
	GLushort vertexFaceCounts[numVertices];
	calcNormals(m.frontTrilist, 
				numXTris, 
				m.vertices, 
				m.vertexNormals, 
				vertexFaceCounts);
	for (int i=0; i<2; i++) {
		calcNormals(m.sideTrilists[i], 
					numZTris,
					m.vertices, 
					m.vertexNormals,
					vertexFaceCounts);
	}
	for (int i=0; i<numTopTrilists; i++) {
		calcNormals(m.topTrilists[i], 
					numZTris, 
					m.vertices, 
					m.vertexNormals,
					vertexFaceCounts);
	}
	
	for (int i=0; i<numVertices; i++) {
		m.vertexNormals[i].x /= (GLfloat)vertexFaceCounts[i];
		m.vertexNormals[i].y /= (GLfloat)vertexFaceCounts[i];
		m.vertexNormals[i].z /= (GLfloat)vertexFaceCounts[i];
	}
#endif
	
	// return newly constructed AudioModel
	return m;
}

void AudioModelSetDimensions(AudioModel* m, GLfloat length, GLfloat width, GLfloat height) {
	// check input params
	if (width < 0 || length < 0 || height < 0) {
		NSLog(@"ERROR (AudioModel.AudioModelMake): Dimensions parameter cannot be less than zero.");
		exit(1);
	}
	
	// assign what we know from params
	m->width = width;
	m->length = length;
	m->height = height;
	
	// recalculate vertex coordinates
	setVertexCoords(m);
}

void AudioModelDrawElements(AudioModel* m) {
	glDrawElements(GL_TRIANGLE_STRIP, m->xTrilistLen, GL_UNSIGNED_SHORT, m->frontTrilist);
	glDrawElements(GL_TRIANGLE_STRIP, m->zTrilistLen, GL_UNSIGNED_SHORT, m->sideTrilists[0]);
	glDrawElements(GL_TRIANGLE_STRIP, m->zTrilistLen, GL_UNSIGNED_SHORT, m->sideTrilists[1]);
	for (int i=0; i<m->numTopTrilists; i++) {
		glDrawElements(GL_TRIANGLE_STRIP, m->zTrilistLen, GL_UNSIGNED_SHORT, m->topTrilists[i]);
	}
}

void AudioModelAddXData(AudioModel* m, GLfloat* newXData, int modelNum) {
	
	// set globals for convenience function
	_xDataLen = m->xDataLen;
	_zDataLen = m->zDataLen;
	
	// move current height and color data back one row
	for (int i=m->zDataLen-2; i>=0; i--) {
		for (int j=0; j<m->xDataLen; j++) {
			GLuint srcInd = vertsTop(j, i);
			GLuint destInd = vertsTop(j, i+1);
			m->vertices[destInd].y = m->vertices[srcInd].y;
			m->colors[destInd] = m->colors[srcInd];
			/*
			if (i != 0) {
				m->colors[destInd] = m->colors[srcInd];
			} else {
				Color3D interpColor = Color3DInterpolate(topColors[0], 
														 topColors[1], 
														 (GLfloat)j/(GLfloat)(m->xDataLen));
				m->colors[destInd] = interpColor;
			}
			*/
		}
	}
	
	// add a new row to front
	GLfloat val;
	for (int i=0; i<m->xDataLen; i++) {
		val = newXData[i];
		val = val > 1.0f ? 1.0f : val;
		val = val < 0.0f ? 0.0f : val;
		GLuint index = vertsTop(i, modelNum);
		m->vertices[index].y = val*m->height;
        
        // DOLHANSKY: Colors are set here
        Color3D newColor;
        
        switch (modelNum) {
            case 0: // Piano model
                newColor.red = 251./255.;
                newColor.green = 176./255.;
                newColor.blue = 59./255.;
                break;
                
            case 1: // Trumpet model
                newColor.red = 0.;
                newColor.green = 173./255.;
                newColor.blue = 238./255.;
                break;
                
            case 2: // Bass model
                newColor.red = 237./255.;
                newColor.green = 30./255.;
                newColor.blue = 121./255.;
                break;
                
            case 3: // Drums model
                newColor.red = 0./255.;
                newColor.green = 250./255.;
                newColor.blue = 0./255.;
                break;

            default:
                break;
        }

//        newColor.alpha = sqrtf(val); // Boost the alpha a little at low values
        newColor.alpha = val*val; // Shrink the alpha a little at low values
        
		m->colors[index] = newColor;
	}
}

void AudioModelDestroy(AudioModel* m) {
	free(m->vertices);
	free(m->colors);
#if USE_VERTEX_NORMALS
	free(m->vertexNormals);
#endif
	for (int i=0; i<m->numTopTrilists; i++) free(m->topTrilists[i]);
	free(m->topTrilists);
	free(m->sideTrilists[0]);
	free(m->sideTrilists[1]);
}