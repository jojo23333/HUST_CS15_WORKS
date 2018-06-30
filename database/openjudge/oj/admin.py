from django.contrib import admin

# Register your models here.

from .models import UserProfile, Problem, Submission, Contest

admin.site.register(UserProfile)
admin.site.register(Problem)
admin.site.register(Submission)
admin.site.register(Contest)