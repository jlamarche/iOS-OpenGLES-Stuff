bl_info = {
	"name": "Export Objective-C Header (.h)",
	"author": "Jeff LaMarche",
	"version": (1, 0),
	"blender": (2, 5, 7),
	"api": 35622,
	"location": "File > Export",
	"description": "Export Model to Objective-C Header file",
	"warning": "",
	"wiki_url": "",
	"tracker_url": "",
	"category": "Import-Export"}

'''
Usage Notes:


'''

import bpy
from bpy.props import *
import mathutils, math, struct
import os
from os import remove
import time
from io_utils import ExportHelper
import time
import shutil
import bpy
import mathutils

def triangulateNMesh(object):
	bneedtri = False
	scene = bpy.context.scene
	bpy.ops.object.mode_set(mode='OBJECT')
	for i in scene.objects: i.select = False #deselect all objects
	object.select = True
	scene.objects.active = object #set the mesh object to current
	print("Checking mesh if needs to convert quad to Tri...")
	for face in object.data.faces:
		if (len(face.vertices) > 3):
			bneedtri = True
			break
	
	bpy.ops.object.mode_set(mode='OBJECT')
	if bneedtri == True:
		print("Converting quad to tri mesh...")
		me_da = object.data.copy() #copy data
		me_ob = object.copy() #copy object
		#note two copy two types else it will use the current data or mesh
		me_ob.data = me_da
		bpy.context.scene.objects.link(me_ob)#link the object to the scene #current object location
		for i in scene.objects: i.select = False #deselect all objects
		me_ob.select = True
		scene.objects.active = me_ob #set the mesh object to current
		bpy.ops.object.mode_set(mode='EDIT') #Operators
		bpy.ops.mesh.select_all(action='SELECT')#select all the face/vertex/edge
		bpy.ops.mesh.quads_convert_to_tris() #Operators
		bpy.context.scene.update()
		bpy.ops.object.mode_set(mode='OBJECT') # set it in object
		print("Triangulate Mesh Done!")
		print("Remove Merge tmp Mesh [ " ,object.name, " ] from scene!" )
		bpy.ops.object.mode_set(mode='OBJECT') # set it in object
		bpy.context.scene.objects.unlink(object)
	else:
		print("No need to convert tri mesh.")
		me_ob = object
	return me_ob


def writeString(file, string):
	file.write(bytes(string, 'UTF-8'))
	
def do_export(context, props, filepath):
	mat_x90 = mathutils.Matrix.Rotation(-math.pi/2, 4, 'X')
	ob = context.active_object
	me_ob = triangulateNMesh(ob)
	current_scene = context.scene	
	apply_modifiers = props.apply_modifiers

	mesh = me_ob.to_mesh(current_scene, apply_modifiers, 'PREVIEW')
	
	basename = mesh.name.capitalize()
	
	if props.world_space:
		mesh.transform(ob.matrix_world)

	if props.rot_x90:
		mesh.transform(mat_x90)

	file = open(filepath, "wb") 
	theHeader = '//If not using MC3D, change 1 to 0 to add needed types\n#if 1\n\t#import "MC3DTypes.h"\n#else\n\
	struct texCoord\n\
	{\n\
		GLfloat		u;\n\
		GLfloat		v;\n\
	};\n\
	typedef struct texCoord texCoord;\n\
	typedef texCoord* texCoordPtr;\n\
\n\
	typedef struct vec2 vec2;\n\
	typedef vec2* vec2Ptr;\n\
\n\
	struct vec3\n\
	{\n\
		GLfloat x;\n\
		GLfloat y;\n\
		GLfloat z;\n\
	};\n\
\n\
	typedef struct vec3 vec3;\n\
	typedef vec3* vec3Ptr;\n\
\n\
	struct vec4\n\
	{\n\
		GLfloat x;\n\
		GLfloat y;\n\
		GLfloat z;\n\
		GLfloat w;\n\
		};\n\
\n\
	typedef struct vec4 vec4;\n\
	typedef vec4* vec4Ptr;\n\
	\n\
#endif\n\
\n'
	writeString(file, theHeader)

	if len(mesh.uv_textures) > 0:
		writeString(file, 'struct vertexDataTextured\n\
{\n\
	vec3		vertex;\n\
	vec3		normal;\n\
	texCoord	texCoord;\n\
}\n\
typedef struct vertexDataTextured vertexDataTextured;\n\
typedef vertexDataTextured* vertexDataTexturedPtr;\n\n\n')
		writeString(file, 'static const vertexDataTextured %sVertexData[] = {\n' % basename)
		#for face in uv: #loop through the faces
		uv_layer = mesh.uv_textures.active
		for face in mesh.faces:
			faceUV = uv_layer.data[face.index]
			i=0
			for index in face.vertices:
				if len(face.vertices) == 3:
					vert = mesh.vertices[index]
					writeString(file, '\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
					writeString(file, '/*n:*/{%f, %f, %f}, ' % (vert.normal.x, vert.normal.y, vert.normal.z))
					writeString(file, '/*t:*/{%f, %f}' % ( faceUV.uv[i][0], faceUV.uv[i][1] ) )
					writeString(file, '},\n')
					i+=1
		writeString(file, '};\n\n')
	elif len(mesh.vertex_colors) > 0:
		writeString(file, 'struct vertexDataColored\n\
{\n\
	vec3		vertex;\n\
	vec3		normal;\n\
	vec4		color;\n\
}\n\
typedef struct vertexDataColored vertexDataColored;\n\
typedef vertexDataColored* vertexDataColoredPtr;\n\n\n')
		writeString(file, 'static const vertexDataColored %sVertexData[] = {\n' % basename)
		color_layer = mesh.active_vertex_color
		for face in mesh.faces:
			if len(face.vertices) == 3:
				faceC = color_layer.data[face.index]
				i=0
				for index in face.vertices:
					vert = mesh.vertices[index]
					writeString(file, '\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
					writeString(file, '/*n:*/{%f, %f, %f}, ' % (vert.normal.x, vert.normal.y, vert.normal.z))
					writeString(file, '/*c:*/{%f, %f, %f, %f}' % ( faceC.color1[i], faceC.color2[i], faceC.color3[i], faceC.color4[i]) )
					writeString(file, '},\n')
					i+=1
		writeString(file, '};\n\n')
	else:
		writeString(file, 'struct vertexData\n\
{\n\
	vec3		vertex;\n\
	vec3		normal;\n\
}\n\
typedef struct vertexData vertexData;\n\
typedef vertexData* vertexDataPtr;\n\n\n')
		writeString(file, 'static const vertexData %sVertexData[] = {\n' % basename)
		for face in mesh.faces:
			if len(face.vertices) == 3:
				for index in face.vertices:
					vert = mesh.vertices[index]
					writeString(file, '\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
					writeString(file, '/*n:*/{%f, %f, %f} ' % (vert.normal.x, vert.normal.y, vert.normal.z))
					writeString(file, '},\n')
		writeString(file, '};\n\n')
	
	writeString(file, '// Example OpenGL ES 1.1 Drawing Code:\n')
	writeString(file, '// glEnableClientState(GL_VERTEX_ARRAY);\n')
	if len(mesh.uv_textures) > 0:
		writeString(file, '// glEnableClientState(GL_TEXTURE_COORD_ARRAY);\n')
	elif len(mesh.vertex_colors) > 0:
		writeString(file, '// glEnableClientState(GL_COLOR_ARRAY);\n')
		writeString(file, '// glEnable(GL_COLOR_MATERIAL)\n')
	writeString(file, '// glEnableClientState(GL_NORMAL_ARRAY);\n')
	writeString(file, '// glVertexPointer(3, GL_FLOAT, sizeof(')
	if len(mesh.uv_textures) > 0:
		writeString(file, 'TexturedVertexData3D')
	elif len(mesh.vertex_colors) > 0:
		writeString(file, 'ColoredVertexData3D')
	else:
		writeString(file, 'VertexData3D')
	writeString(file, '), &%sVertexData[0].vertex);\n' % basename)
	writeString(file, '// glNormalPointer(GL_FLOAT, sizeof(')
	if len(mesh.uv_textures) > 0:
		writeString(file, 'TexturedVertexData3D')
	elif len(mesh.vertex_colors) > 0:
		writeString(file, 'ColoredVertexData3D')
	else:
		writeString(file, 'VertexData3D')
	writeString(file, '), &%sVertexData[0].normal);\n' % basename)
	if len(mesh.uv_textures) > 0:
		writeString(file, '// glTexCoordPointer(2, GL_FLOAT, sizeof(TexturedVertexData3D), &%sVertexData[0].texCoord);\n' % basename)
	elif len(mesh.vertex_colors) > 0:
		writeString(file, '// glColorPointer(4, GL_FLOAT, sizeof(ColoredVertexData3D), &%sVertexData[0].color);\n' % basename)
	writeString(file, '// glDrawArrays(GL_TRIANGLES, 0, k%sNumberOfVertices);\n' % basename)
	writeString(file, '// glDisableClientState(GL_VERTEX_ARRAY);\n')
	if len(mesh.uv_textures) > 0:
		writeString(file, '// glDisableClientState(GL_TEXTURE_COORD_ARRAY);\n')
	elif len(mesh.vertex_colors) > 0:
		writeString(file, '// glDisableClientState(GL_NORMAL_ARRAY);\n')
		writeString(file, '// glDisable(GL_COLOR_MATERIAL);\n')
	writeString(file, '// glDisableClientState(GL_NORMAL_ARRAY);\n\n\n')
	
	
	file.flush()
	file.close()

	return True


###### EXPORT OPERATOR #######
class Export_objc(bpy.types.Operator, ExportHelper):
	'''Exports the active Object as an Objective-C Header File.'''
	bl_idname = "export_object.objc"
	bl_label = "Export Objective-C Header (.h)"

	filename_ext = ".h"
	
	apply_modifiers = BoolProperty(name="Apply Modifiers",
							description="Applies the Modifiers",
							default=True)

	rot_x90 = BoolProperty(name="Convert to Y-up",
							description="Rotate 90 degrees around X to convert to y-up",
							default=True)
	
	world_space = BoolProperty(name="Export into Worldspace",
							description="Transform the Vertexcoordinates into Worldspace",
							default=False)

	
	@classmethod
	def poll(cls, context):
		return context.active_object.type in ['MESH', 'CURVE', 'SURFACE', 'FONT']

	def execute(self, context):
		start_time = time.time()
		print('\n_____START_____')
		props = self.properties
		filepath = self.filepath
		filepath = bpy.path.ensure_ext(filepath, self.filename_ext)

		exported = do_export(context, props, filepath)
		
		if exported:
			print('finished export in %s seconds' %((time.time() - start_time)))
			print(filepath)
			
		return {'FINISHED'}

	def invoke(self, context, event):
		wm = context.window_manager

		if True:
			# File selector
			wm.fileselect_add(self) # will run self.execute()
			return {'RUNNING_MODAL'}
		elif True:
			# search the enum
			wm.invoke_search_popup(self)
			return {'RUNNING_MODAL'}
		elif False:
			# Redo popup
			return wm.invoke_props_popup(self, event) #
		elif False:
			return self.execute(context)


### REGISTER ###

def menu_func(self, context):
	self.layout.operator(Export_objc.bl_idname, text="Objective-C Header (.h)")

def register():
	bpy.utils.register_module(__name__)

	bpy.types.INFO_MT_file_export.append(menu_func)

def unregister():
	bpy.utils.unregister_module(__name__)

	bpy.types.INFO_MT_file_export.remove(menu_func)

if __name__ == "__main__":
	register()
