from django.contrib import admin

# Register your models here.
from .models import Todo

class TodoAdmin(admin.ModelAdmin):
    fields = ['title', 'description', 'to_be_done']
     
     
admin.site.register(Todo, TodoAdmin)
