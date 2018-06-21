# Generated by Django 2.0.5 on 2018-06-21 17:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('oj', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='userprofile',
            name='creation_date',
        ),
        migrations.AlterField(
            model_name='contest',
            name='end_time',
            field=models.DateTimeField(),
        ),
        migrations.AlterField(
            model_name='contest',
            name='start_time',
            field=models.DateTimeField(),
        ),
        migrations.AlterField(
            model_name='submission',
            name='run_time',
            field=models.FloatField(default=0),
        ),
        migrations.AlterField(
            model_name='submission',
            name='submit_time',
            field=models.DateTimeField(auto_now=True),
        ),
    ]