//
//  Camera3D.h
//  Spectrum3D
//
//  Created by Garth Griffin on 5/14/10.
//  Copyright Garth Griffin 2010. 
//

#import "OpenGLCommon.h"
#import "gluLookAt.h"

typedef struct {
	Vertex3D eye;
	Vertex3D center;
	Vector3D up;
} Camera3D;

static inline void Camera3DLookAt(Camera3D camera) {
	gluLookAt(camera.eye.x,		camera.eye.y,		camera.eye.z, 
			  camera.center.x,	camera.center.y,	camera.center.z, 
			  camera.up.x,		camera.up.y,		camera.up.z);
}

Camera3D Camera3DMake(Vertex3D eye, Vertex3D center, Vector3D up);