from django.shortcuts import render
from .models import Todo
from api.serializers import TodoSerializer
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

# Create your views here.

class TodoList(APIView):
    
    def get(self, request, format=None):
        
        todos = Todo.objects.all()
        serializer = TodoSerializer(todos, many=True)
        return Response(serializer.data)
    
    def post(self, request, format=None):
        serializer = TodoSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    
class TodoDetails(APIView):
    def get_object(self,pk:None):
        try:
            return Todo.objects.get(pk=pk)
        except Todo.DoesNotExist:
            raise Http404
        
    def get(self, request, pk=None, format=None):
        todo = self.get_object(pk=pk)
        serializer = TodoSerializer (todo)
        return Response(serializer.data)
 
        

