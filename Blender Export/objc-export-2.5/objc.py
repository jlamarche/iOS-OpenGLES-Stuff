#!BPY

"""
Name: 'Objective-C Header (.h)'
Blender: 244
Group: 'Export'
Tooltip: 'Exports header file for use with the OpenGL ES template for iPhone available from http://iphonedevelopment.blogspot.com/'
"""
import Blender
from Blender import Mathutils
from Blender.Mathutils import *
import bpy
import os

def write_obj(filepath):    
   out = file(filepath, 'w')
   sce = bpy.data.scenes.active
   ob = sce.objects.active
   mesh = ob.getData(mesh=1)
   objectname = ob.getData(True)
   basename = objectname.capitalize()

   out.write('#import "OpenGLCommon.h"\n\n\n')
   out.write('static const TexturedVertexData3D %sVertexData[] = {\n' % basename)
   for face in mesh.faces:
       for (vert, uvert) in zip(face.v, face.uv):
           out.write('\t{/*v:*/{%f, %f, %f}, ' % (vert.co.x, vert.co.y, vert.co.z) )
           out.write('/*n:*/{%f, %f, %f}, ' % (vert.no.x, vert.no.y, vert.no.z))
           out.write('/*t:*/{%f, %f}' % ( uvert.x, uvert.y ) )
           out.write('},\n')
   out.write('};\n\n')

   out.write('#define k%sNumberOfVertices\t%i\n' % (basename, len(mesh.faces) * 3) )

   out.write('// Drawing Code:')
   out.write('// glEnableClientState(GL_VERTEX_ARRAY);\n')
   out.write('// glEnableClientState(GL_TEXTURE_COORD_ARRAY);\n')
   out.write('// glEnableClientState(GL_NORMAL_ARRAY);\n')
   out.write('// glVertexPointer(3, GL_FLOAT, sizeof(TexturedVertexData3D), &%sVertexData[0].vertex);\n' % basename)
   out.write('// glNormalPointer(GL_FLOAT, sizeof(TexturedVertexData3D), &%sVertexData[0].normal);\n' % basename)
   out.write('// glTexCoordPointer(2, GL_FLOAT, sizeof(TexturedVertexData3D), &%sVertexData[0].texCoord);\n' % basename)
   out.write('// glDrawArrays(GL_TRIANGLES, 0, k%sNumberOfVertices);\n' % basename)
   out.write('// glDisableClientState(GL_VERTEX_ARRAY);\n')
   out.write('// glDisableClientState(GL_TEXTURE_COORD_ARRAY);\n')
   out.write('// glDisableClientState(GL_NORMAL_ARRAY);\n\n\n')

   out.close()

filename = os.path.splitext(Blender.Get('filename'))[0]
Blender.Window.FileSelector(write_obj, "Export", '%s.h' % filename