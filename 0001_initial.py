# Generated by Django 2.0.5 on 2018-06-17 17:46

from django.db import migrations, models
import django.db.models.deletion
import oj.models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Problem',
            fields=[
                ('pid', models.IntegerField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=30)),
                ('describtion', models.CharField(max_length=500)),
                ('sample_input', models.CharField(max_length=500)),
                ('sample_output', models.CharField(max_length=500)),
                ('std', models.FileField(upload_to='./stds/<django.db.models.fields.IntegerField>')),
            ],
        ),
        migrations.CreateModel(
            name='Submission',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('source', models.FileField(upload_to=oj.models.submit_source_path)),
                ('language', models.CharField(choices=[('c', 'C'), ('cpp', 'C++'), ('java', 'Java')], max_length=5)),
                ('judge_time', models.DateField()),
                ('run_time', models.FloatField()),
                ('status', models.CharField(choices=[('AC', 'Accepted'), ('WA', 'Wrong Answer'), ('TLE', 'Time Limit Exceed'), ('MLE', 'Memory Limit Exceed'), ('PD', 'Pending')], default='PD', max_length=5)),
                ('problem', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='oj.Problem')),
            ],
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('uid', models.CharField(max_length=30, primary_key=True, serialize=False)),
                ('email', models.CharField(max_length=30)),
                ('password', models.CharField(max_length=30)),
                ('creation_date', models.DateField()),
                ('is_super_user', models.BooleanField()),
            ],
        ),
        migrations.AddField(
            model_name='submission',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='oj.User'),
        ),
    ]