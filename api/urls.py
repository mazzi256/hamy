from django.urls import path
from rest_framework.urlpatterns import format_suffix_patterns
from api.views import TodoDetails, TodoList

urlpatterns = [
    path('todos/', TodoList.as_view()),
    path('todo/<int:pk>/', TodoDetails.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
