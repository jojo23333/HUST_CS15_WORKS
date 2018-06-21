from django.db import models
from django.conf import settings
from datetime import datetime
import os

# Create your models here.
class UserProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    is_super_user = models.BooleanField()

    def __str__(self):
        return str(self.id) + " SuperUser:" + str(self.is_super_user)


class Problem(models.Model):
    LANGUAGE = (
        ('c', 'C'),
        ('cpp', 'C++'),
        ('java', 'Java')
    )
    pid = models.AutoField( primary_key = True)
    name = models.CharField( max_length= 30)
    description = models.TextField(default="")
    sample_input = models.TextField(default="")
    sample_output = models.TextField(default="")
    std = models.TextField(default="")
    std_language = models.CharField(max_length=5, choices = LANGUAGE, default='c')

    def __str__(self):
        return self.name


def submit_source_path(object, filename):
    time = datetime(object.judge_time)
    return os.path.join("./submissions/",time.strftime("_%Y_%m_%d_%H_%M_%S_"), object.user.uid + '_'\
                        + object.problem.name +  '.' + object.language)

class Submission(models.Model):
    JUDGE_STATUS = (
        ('AC', "Accepted"),
        ('WA', "Wrong Answer"),
        ('TLE', "Time Limit Exceed"),
        ('MLE', "Memory Limit Exceed"),
        ('PD', "Pending")
    )
    LANGUAGE = (
        ('c', 'C'),
        ('cpp', 'C++'),
        ('java', 'Java')
    )

    JUDGE_DICT = dict(JUDGE_STATUS)

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete = models.CASCADE)
    problem = models.ForeignKey(Problem, on_delete = models.CASCADE)
    source = models.TextField(default="")
    language = models.CharField(max_length=5, choices = LANGUAGE, default='c')
    submit_time = models.DateTimeField(auto_now=True)
    run_time = models.FloatField(default=0)
    status = models.CharField(max_length= 5, choices = JUDGE_STATUS, default='PD')

    def __str__(self):
        return self.user.username + '-' + str(self.problem.pid) + '-' +str(self.id)

    def get_status(self):
        return self.JUDGE_DICT[self.status]


class Contest(models.Model):
    AUTHORITY_CLASS = (
        (1, 'public'),
        (2, 'private'),
        (3, 'protected')
    )

    name = models.CharField(max_length=30)
    description = models.TextField(default="")
    creater = models.ForeignKey(settings.AUTH_USER_MODEL, null=True, on_delete=models.SET_NULL)
    authority_class = models.SmallIntegerField(choices=AUTHORITY_CLASS, default=1)
    problem_set = models.ManyToManyField(Problem)
    submission_set = models.ManyToManyField(Submission)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()

    def __str__(self):
        return self.name + self.description
