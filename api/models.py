from django.db import models

# Create your models here.

class BaseModel(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)
    
class Todo(BaseModel):
    title = models.CharField(max_length=200,default=None, help_text="Title")
    description = models.TextField(max_length=200)
    database = models.DateField(auto_now_add=False)
    
    def __str__(self):
        return self.title
    
    
        
    
