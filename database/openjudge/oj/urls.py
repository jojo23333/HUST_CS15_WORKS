from django.urls import path
from django.contrib.auth import views as auth_views

from . import views

urlpatterns = [
    path('', views.indexView.as_view(), name='index'),
    path('login/', views.loginView.as_view(), name='login_view'),
    path('logout/',views.logoutView, name='logout_view'),
    path('register/', views.registerView.as_view(), name='register_view'),
    path('problems/', views.problemListView.as_view(), name='problem_listview'),
    path('problems/<int:pk>', views.problemDetailView.as_view(), name='problem_listview'),
    path('problems/submit', views.submitView.as_view(), name='submit_view'),
    path('submissions/', views.submissionListView.as_view(), name='submission_listview'),
    path('submissions/<int:pk>', views.submissionDetailView.as_view(), name='submission_detailview'),
    path('contests', views.contestListView.as_view(), name='contest_listview'),
]