# Generated by Django 2.0.5 on 2018-06-21 12:46

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Contest',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=30)),
                ('description', models.TextField(default='')),
                ('problem_count', models.IntegerField()),
                ('start_time', models.DateField()),
                ('end_time', models.DateField()),
            ],
        ),
        migrations.CreateModel(
            name='Problem',
            fields=[
                ('pid', models.AutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=30)),
                ('description', models.TextField(default='')),
                ('sample_input', models.TextField(default='')),
                ('sample_output', models.TextField(default='')),
                ('std', models.TextField(default='')),
                ('std_language', models.CharField(choices=[('c', 'C'), ('cpp', 'C++'), ('java', 'Java')], default='c', max_length=5)),
            ],
        ),
        migrations.CreateModel(
            name='Submission',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('source', models.TextField(default='')),
                ('language', models.CharField(choices=[('c', 'C'), ('cpp', 'C++'), ('java', 'Java')], default='c', max_length=5)),
                ('submit_time', models.DateField(auto_now=True)),
                ('run_time', models.FloatField()),
                ('status', models.CharField(choices=[('AC', 'Accepted'), ('WA', 'Wrong Answer'), ('TLE', 'Time Limit Exceed'), ('MLE', 'Memory Limit Exceed'), ('PD', 'Pending')], default='PD', max_length=5)),
                ('problem', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='oj.Problem')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='UserProfile',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('creation_date', models.DateField(auto_now_add=True)),
                ('is_super_user', models.BooleanField()),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.AddField(
            model_name='contest',
            name='problem_set',
            field=models.ManyToManyField(to='oj.Problem'),
        ),
        migrations.AddField(
            model_name='contest',
            name='submission_set',
            field=models.ManyToManyField(to='oj.Submission'),
        ),
    ]
