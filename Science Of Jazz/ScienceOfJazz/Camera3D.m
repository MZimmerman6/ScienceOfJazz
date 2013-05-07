//
//  Camera3D.m
//  Spectrum3D
//
//  Created by Garth Griffin on 5/14/10.
//  Copyright Garth Griffin 2010. 
//

#import "Camera3D.h"

Camera3D Camera3DMake(Vertex3D eye, Vertex3D center, Vector3D up) {
	Camera3D cam;
	cam.eye = eye;
	cam.center = center;
	cam.up = up;
	return cam;
}