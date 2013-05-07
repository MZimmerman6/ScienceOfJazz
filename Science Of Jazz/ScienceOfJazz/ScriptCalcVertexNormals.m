//
//  ScriptCalcVertexNormals.m
//  Spectrum3D
//
//  Created by Garth Griffin on 5/12/10.
//  Copyright Garth Griffin 2010. 
//

#import <Foundation/Foundation.h>
#import "OpenGLCommon.h"

#define CUBE 0
#define ICOS 0
#define RECT 0

#if ICOS
const Vertex3D vertices[]= {
	{0, -0.525731, 0.850651},             // vertices[0]
	{0.850651, 0, 0.525731},              // vertices[1]
	{0.850651, 0, -0.525731},             // vertices[2]
	{-0.850651, 0, -0.525731},            // vertices[3]
	{-0.850651, 0, 0.525731},             // vertices[4]
	{-0.525731, 0.850651, 0},             // vertices[5]
	{0.525731, 0.850651, 0},              // vertices[6]
	{0.525731, -0.850651, 0},             // vertices[7]
	{-0.525731, -0.850651, 0},            // vertices[8]
	{0, -0.525731, -0.850651},            // vertices[9]
	{0, 0.525731, -0.850651},             // vertices[10]
	{0, 0.525731, 0.850651}               // vertices[11]
};
const int numVertices = 12;

const GLubyte faces[] = {
	1, 2, 6,
	1, 7, 2,
	3, 4, 5,
	4, 3, 8,
	6, 5, 11,
	5, 6, 10,
	9, 10, 2,
	10, 9, 3,
	7, 8, 9,
	8, 7, 0,
	11, 0, 1,
	0, 11, 4,
	6, 2, 10,
	1, 6, 11,
	3, 5, 10,
	5, 4, 11,
	2, 7, 9,
	7, 1, 0,
	3, 9, 8,
	4, 8, 0,
};
const int numFaces = 20;

// faces are triangles
const BOOL facesAreTriangleSplits = NO;
#endif

#if CUBE
// vertices
const Vertex3D vertices[] = {
	{-.5,0.5,0.5},	// 0
	{-.5,-.5,0.5},	// 1
	{0.5,0.5,0.5},	// 2
	{0.5,-.5,0.5},	// 3
	{-.5,0.5,-.5},	// 4
	{-.5,-.5,-.5},	// 5
	{0.5,0.5,-.5},	// 6
	{0.5,-.5,-.5}	// 7
};

// faces
const GLubyte faces[] = {
	//6,4,7,5,1,4,0,6,2,7,3,1,2,0 // failed strip list from website
	//2,0,3,1,5,0,4,2,6,3,7,5,6,4 // failed strip list by hand
	
	2,0,3,
	3,0,1,
	3,1,7,
	7,1,5,
	6,7,5,
	6,5,4,
	2,6,4,
	2,4,0,
	1,0,4,
	1,4,5,
	7,6,2,
	7,2,3
	
};

// counts
const int numVertices = 8;
const int numFaces = 12;

// faces are triangle splits
const BOOL facesAreTriangleSplits = NO;
#endif

#ifdef RECT

 
 
 static const GLfloat texCoords[] = {
 0.0, 1.0,
 0.0, 0.0,
 1.0, 1.0,
 1.0, 0.0,
 1.0, 1.0,
 1.0, 0.0,
 0.0, 1.0,
 0.0, 0.0
 };



const Vertex3D vertices[] = {
	{-128.0,	64.0,	0.0},		// 0
	{-128.0,	0.0,	0.0},		// 1
	{128.0,		64.0,	0.0},		// 2
	{128.0,		0.0,	0.0},		// 3
	{-128.0,	64.0,	-512.0},	// 4
	{-128.0,	0.0,	-512.0},	// 5
	{128.0,		64.0,	-512.0},	// 6
	{128.0,		0.0,	-512.0}		// 7
};

const GLubyte faces[] = {
	1,2,0,
	3,2,1,
	7,6,2,
	2,3,7,
	0,4,5,
	0,5,1,
	6,4,5,
	6,5,7,
	6,4,0,
	6,0,2,
	7,5,1,
	7,1,3
};

const int numVertices = 8;
const int numFaces = 12;
const BOOL facesAreTriangleSplits = NO;
#endif


// debug
#define DEBUG_SURFACE 0
#define DEBUG_VERTEX 0

//int main(int argc, char* argv[]) {
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	NSLog(@"Script to calculate normals.");
//	
//	// set up surface output string
//	NSMutableString* surfaceResult = [NSMutableString string];
//	[surfaceResult appendString:@"\n\nconst Vector3D surfaceNormals[] = {\n"];
//	
//	// calculate surface normals
//	Vector3D *surfaceNormals = calloc(numFaces, sizeof(Vector3D));
//	for (int i=0; i<numFaces; i++) {
//		if (DEBUG_SURFACE) NSLog(@">>> FACE %d",i);
//		Vertex3D v1,v2,v3;
//		int firstIndex;
//		if (facesAreTriangleSplits) firstIndex = i;
//		else						firstIndex = i*3;
//		v1 = vertices[faces[firstIndex]];
//		v2 = vertices[faces[firstIndex+1]];
//		v3 = vertices[faces[firstIndex+2]];
//		Triangle3D triangle = Triangle3DMake(v1, v2, v3);
//		if (DEBUG_SURFACE) {
//			NSLog(@"triangle[%02d] = { {%.1f,%.1f,%.1f}, {%.1f,%.1f,%.1f}, {%.1f,%.1f,%.1f} }",i,
//				  triangle.v1.x,
//				  triangle.v1.y,
//				  triangle.v1.z,
//				  triangle.v2.x,
//				  triangle.v2.y,
//				  triangle.v2.z,
//				  triangle.v3.x,
//				  triangle.v3.y,
//				  triangle.v3.z
//				  );
//		}
//		
//		Vector3D surfaceNormal = Triangle3DCalculateSurfaceNormal(triangle);
//		Vector3DNormalize(&surfaceNormal);
//		surfaceNormals[i] = surfaceNormal;
//		[surfaceResult appendFormat:@"\t{%f, %f, %f}",
//		 surfaceNormal.x,surfaceNormal.y,surfaceNormal.z];
//		if (i != numFaces-1) [surfaceResult appendString:@","];
//		[surfaceResult appendString:@"\n"];
//	}
//	
//	// output result string
//	NSLog(@"Printing surface normals...");
//	[surfaceResult appendString:@"};\n\n"];
//	NSLog(@"%@",surfaceResult);
//	
//	// set up vertex output string
//	NSMutableString *vertexResult = [NSMutableString string];
//	[vertexResult appendString:@"\n\nconst Vector3D vertexNormals[] = {\n"];
//	
//	// calculate vertex normals
//	Vertex3D *normals = calloc(numVertices, sizeof(Vertex3D));
//	for (int i=0; i<numVertices; i++) {
//		if (DEBUG_VERTEX) NSLog(@">>> VERTEX %d",i);
//		
//		// count number of faces containing this vertex
//		int faceCount = 0;
//		for (int j=0; j<numFaces; j++) {
//			
//			// check the three vertices of every face
//			BOOL contains = NO;
//			for (int k=0; k<3; k++) {
//				int firstIndex;
//				if (facesAreTriangleSplits) firstIndex = j;
//				else						firstIndex = j*3;
//				if (faces[firstIndex+k] == i) contains = YES;
//			}
//			
//			// if the face contains the vertex, increment faceCount and add the vector
//			if (contains) {
//				if (DEBUG_VERTEX) NSLog(@"face %d contains vertex %d",j,i);
//				faceCount++;
//				normals[i] = Vector3DAdd(normals[i], surfaceNormals[j]);
//			}
//		}
//		if (DEBUG_VERTEX) NSLog(@"faceCount[%d] = %d",i,faceCount);
//		
//		// normalize the vertex normal by dividing by the number of faces
//		normals[i].x /= (GLfloat)faceCount;
//		normals[i].y /= (GLfloat)faceCount;
//		normals[i].z /= (GLfloat)faceCount;
//		
//		// add the result to the string
//		[vertexResult appendFormat:@"\t{%f, %f, %f}",
//		 normals[i].x,normals[i].y,normals[i].z];
//		if (i != numVertices-1) [vertexResult appendString:@","];
//		[vertexResult appendString:@"\n"];
//	}
//	
//	// output result string
//	NSLog(@"Printing vertex normals...");
//	[vertexResult appendString:@"};\n\n"];
//	NSLog(@"%@",vertexResult);
//	
//	// clean up
//	[pool drain];
//	return 0;
//}
