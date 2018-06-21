# Generated by Django 2.0.5 on 2018-06-21 20:38

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('oj', '0002_auto_20180621_1730'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='contest',
            name='problem_count',
        ),
        migrations.AddField(
            model_name='contest',
            name='authority_class',
            field=models.SmallIntegerField(choices=[(1, 'public'), (2, 'private'), (3, 'protected')], default=1),
        ),
        migrations.AddField(
            model_name='contest',
            name='creater',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL),
        ),
    ]